require_relative './google_api'
require_relative './http_util'
require 'time'
require 'set'

module YoutubeTools
  class VideoCollector
    def initialize(host, logger)
      @url = "http://#{host}/api/v1.0/youtube_uploads"
      @uploadUrl =  "http://#{host}/api/v1.0/video_uploads" 
      @logger, @token, @expired_at = logger, nil, 0
    end

    def run(stopIfNoNew)
      pageToken = nil
      while (true)
        updateToken
        if @token.nil?
          @logger.error("Failed to acquire valid token")
          return
        end

        vids, pageToken = GoogleAPI::YoutubeAPI.getVideoIds(@token, pageToken, @logger)
        if vids.nil?
          @logger.error("Failed to search youtube videos")
          return
        end

        newVids = vids.select{|id| !exist?(id)}
        if newVids.size > 0
          updateToken
          videos = GoogleAPI::YoutubeAPI.getVideoInfo(@token, newVids, @logger)
          videos.each do |vid, info|
            HttpUtil.post(@url, {'Content-Type' => 'application/json'}, info.to_json)
            HttpUtil.post(@uploadUrl, {'Content-Type' => 'application/json'}, {"video_id" => -1, "host" => "youtube", "host_id" => info["youtube_id"]}.to_json)
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
      res = HttpUtil.get(@url + "/" + youtube_id, {})
      return res.kind_of? Net::HTTPSuccess
    end
  end

  class VideoConverter
    def initialize(host, logger)
      @url = "http://#{host}/api/v1.0/"
      @logger = logger

      res = HttpUtil.get(@url + "video_categories", {})
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

      return "未設定"
    end
    
    def run(numVideos)
      count = 0
      while (true)
        res = HttpUtil.get(@url + "video_uploads?video_id=-1&host=youtube&limit=1", {})
        break if !res.kind_of? Net::HTTPSuccess
        uploads = JSON.parse(res.body)
        break if uploads.size == 0
        uploads.each do |upload|
          puts upload["host_id"]
          res = HttpUtil.get(@url + "youtube_uploads/" + upload["host_id"], {})
          raise "Failed to get youtube video info " + res.body if !res.kind_of? Net::HTTPSuccess
          info = JSON.parse(res.body)

          category = getCategory(info)
          body = {
            "duration" => info["duration"],
            "title" => info["title"].gsub("_", " ").
                gsub("UChannel 1.9", "").
                gsub("U Channel 1.9", "").
                gsub("UChannel1.9", "").
                gsub("U Channel 1 9", "").
                gsub("UChannelTV", "").
                gsub("UChennelTV", "").
                gsub("UChannel TV", "").
                gsub("UchannelTV", "").
                gsub("優視" + category, "").
                gsub("FocusNews", "").
                gsub("Focus News", "").
                gsub("News Focus", "").
                gsub("News Topic", "").
                gsub("財經趨勢", "").
                gsub("Financial Trend", "").
                gsub("Finance Focus", "").
                gsub("Focus Finance", "").
                gsub("FocusFinance", "").
                gsub("Weekly Announcement", "").
                gsub("Announcement Weekly", "").
                gsub("Community News", "").
                gsub("Bay Area News", "").
                gsub("U Travel", "").
                gsub("UTravel", "").
                gsub("U旅遊", "").
                gsub("灣 區 資 訊 站", "").
                gsub("灣區資訊站", "").
                gsub("Popcorn Theater", "").
                gsub("爆米花電影院", "").
                gsub("U 廚房 Kitchen", "").
                gsub("U 廚房", "").
                gsub("U Kitchen", "").
                gsub("星馬泰系列", "").
                gsub("社區看板", "").
                gsub("矽谷龍門陣", "").
                gsub("U 體育", "").
                gsub("U體育", "").
                gsub("U Sport", "").
                gsub("U 音樂", "").
                gsub("U Music", "").
                gsub("UMusic", "").
                gsub("優視體育綜合報導", "").
                gsub("生活萬花筒", "").
                gsub("優視社區活動看板", "").
                gsub("優勢社區活動看板", "").
                gsub("Weekly Bulletin", "").
                gsub("｜", " ").
                gsub("UChannel Bulletin", "").
                gsub("＿", " ").
                gsub("|", " ").
                gsub("：", " ").
                gsub(/ +/, " ").strip,
            "description" => info["description"],
            "tags" => info["tags"],
            "category" => category,
            "created_at" => info["published_at"],
            "thumbnail" => info["thumbnail_medium"]
          }.to_json
          res = HttpUtil.post(@url + "videos", {'Content-Type' => 'application/json'}, body)
          raise "Failed to create video " + res.body if !res.kind_of? Net::HTTPSuccess
          tb = JSON.parse(res.body)
          puts tb["id"]

          body = {
            "video_id" => tb["id"],
            "host" => "youtube",
            "host_id" => upload["host_id"]
          }.to_json
          res = HttpUtil.put(@url + "video_uploads/video", {'Content-Type' => 'application/json'}, body) 
          raise "Failed to set video ID " + res.body if !res.kind_of? Net::HTTPSuccess

          res = HttpUtil.put(@url + "video_uploads/enable", {'Content-Type' => 'application/json'}, body) 
          raise "Failed to enable uploads " + res.body if !res.kind_of? Net::HTTPSuccess
        end
        count += 1
        break if count >=numVideos
      end
    end
  end
end
