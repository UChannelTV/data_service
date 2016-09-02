require_relative './google_api'
require_relative './http_util'
require_relative './uchannel_tools'
require 'time'
require 'set'

module YoutubeTools
  class VideoCollector
    def initialize(host, logger)
      @url = host + "/api/v1.0/youtube_uploads"
      @uploadUrl = host + "/api/v1.0/video_uploads" 
      @logger, @token, @expired_at = logger, nil, 0
      #@youtube_playlist_ids = ["UUJ1vOPpLL48N6qV2noUVouA"]
      @youtube_playlist_ids = ["UUta0SK2fns_-Up9NsAAqZVA", "UU9QotuR3RBijf3UHBs5Jdew"]
      @uchannel_api = UChannelTool::API.new(host, logger)
      @converter = VideoConverter.new(@uchannel_api, host, logger)
    end

    def run(stopIfNoNew)
      @youtube_playlist_ids.each do |id|
        runOne(stopIfNoNew, id)
      end
    end

    def runOne(stopIfNoNew, playListId)
      pageToken = nil
      while (true)
        updateToken
        if @token.nil?
          @logger.error("Failed to acquire valid token")
          return
        end

        vids, pageToken = GoogleAPI::YoutubeAPI.getVideoIds(playListId, @token, pageToken, @logger)
        if vids.nil?
          @logger.error("Failed to search youtube videos")
          return
        end

        newVids = vids.select{|id| !exist?(id)}
        if newVids.size > 0
          updateToken
          videos = GoogleAPI::YoutubeAPI.getVideoInfo(@token, newVids, @logger)
          videos.each do |vid, info|
            res = HttpUtil.post(@url, @uchannel_api.getHeader, info.to_json)
            if !res.kind_of? Net::HTTPSuccess
              @logger.error("Failed to create youtube video " + res.body)
            else
              HttpUtil.post(@uploadUrl, @uchannel_api.getHeader, {"video_id" => -1, "host" => "youtube", "host_id" => info["youtube_id"]}.to_json)
              @converter.save(info)
            end
          end
        end

        puts newVids.size
        break if pageToken.nil?
        break if stopIfNoNew && newVids.size == 0
      end
    end

    def updateToken
      t = Time.now.to_i
      
      if @token.nil? || @expired_at <= t
        @token, exp = GoogleAPI::Auth.refreshToken(@logger)
        @expired_at = t + exp - 60 if !@token.nil?
      end
    end

    def exist?(youtube_id)
      return true if youtube_id.nil?
      res = HttpUtil.get(@url + "/" + youtube_id, @uchannel_api.getHeader)
      return res.kind_of? Net::HTTPSuccess
    end
  end

  class VideoConverter
    def initialize(api, host, logger)
      @api = api
      @url = host + "/api/v1.0/"
      @logger = logger

      res = HttpUtil.get(@url + "video_categories", @api.getHeader)
      raise "Failed to get video categories " + res.body if !res.kind_of? Net::HTTPSuccess

      @categories = Set.new
      JSON.parse(res.body).each do |val|
        @categories << val["name"]
      end
    end

    def getCategory(info)
      @categories.each do |name|
        return name if info["title"].include? name
      end
      @categories.each do |name|
        return name if info["description"].to_s.include? name
      end

      return "社區看板" if info["title"].include? "Community News"
      return "社區看板" if info["title"].include? "Announcement Weekly"
      return "社區看板" if info["title"].include? "社區活動看板"
      return "焦點財經" if info["title"].include? "Focus Finance"
      return "焦點話題" if info["title"].include? "News Topic"
      return "U 旅遊" if info["title"].include? "U Travel"
      return "U 體育" if info["title"].include? "U體育"
      return "U 體育" if info["title"].include? "優視體育"
      return "U 音樂" if info["title"].include? "U Music"
      return "U 音樂" if info["title"].include? "UMusic"
      if !info["tags"].nil?
        return "勵志短片" if info["tags"].join(",").include? "優視原創紀錄片"
        return "親子電影站" if info["tags"].join(",").include? "親子電影站"
      end
      
      return "未設定"
    end
   
    def getVideoInfo(info)
      category = getCategory(info)
      {"duration" => info["duration"],
       "title" => UChannelTool::Content.normalizeTitle(info["title"], category),
       "description" => info["description"],
       "tags" => info["tags"],
       "category" => category,
       "status" => "active",
       "created_at" => info["published_at"],
       "thumbnail" => info["thumbnail_medium"]
      }
    end

    def save(info)
      body = getVideoInfo(info).to_json
      res = HttpUtil.post(@url + "videos", @api.getHeader, body)
      if !res.kind_of? Net::HTTPSuccess
        @logger.error("Failed to create video " + res.body)
        puts info["youtube_id"]
      else
        tb = JSON.parse(res.body)
        puts tb["id"]
      
        body = {
          "video_id" => tb["id"],
          "host" => "youtube",
          "host_id" => info["youtube_id"]
        }.to_json
        res = HttpUtil.put(@url + "video_uploads/video", @api.getHeader, body) 
        raise "Failed to set video ID " + res.body if !res.kind_of? Net::HTTPSuccess

        res = HttpUtil.put(@url + "video_uploads/enable", @api.getHeader, body) 
        raise "Failed to enable uploads " + res.body if !res.kind_of? Net::HTTPSuccess
      end
    end

    def run(numVideos)
      count = 0
      while (true)
        res = HttpUtil.get(@url + "video_uploads?video_id=-1&host=youtube", @api.getHeader)
        break if !res.kind_of? Net::HTTPSuccess
        uploads = JSON.parse(res.body)
        break if uploads.size == 0
        uploads.each do |upload|
          puts upload["host_id"]
          res = HttpUtil.get(@url + "youtube_uploads/" + upload["host_id"], @api.getHeader)
          if !res.kind_of? Net::HTTPSuccess
            @logger.error("Failed to get youtube video info " + res.body)
            next
          end
          
          info = JSON.parse(res.body)
          save(info)

          count += 1
          return if count >= numVideos
        end
      end
    end
  end
end
