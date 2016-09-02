require_relative './http_util'
require_relative './uchannel_tools'
require 'vimeo'
require 'time'
require 'set'

module VimeoTools
  class VimeoChannels
    def initialize
      @channels = {"1119318" => "理財妙管家",
                   "1086749" => "U 體育",
                   "1080039" => "勵志短片",
                   "1002910" => "U 音樂",
                   "988188" => "U 旅遊",
                   "987324" => "親子電影站",
                   "985357" => "未設定",
                   "985356" => "未設定",
                   "984813" => "星馬泰美食",
                   "982231" => "灣區資訊站",
                   "928058" => "矽谷龍門陣",
                   "915158" => "焦點話題",
                   "869382" => "生活萬花筒",
                   "868287" => "財經趨勢",
                   "831185" => "生活萬花筒",
                   "799209" => "真愛公益站",
                   "796108" => "社區看板",
                   "782550" => "跨越的人生",
                   "782549" => "焦點新聞",
                   "759796" => "焦點財經"}
    end

    def channelIds
      @channels.keys
    end

    def channelName(id)
      @channels[id]
    end
  end

  class VideoCollector  
    def initialize(host, logger)
      @url = host + "/api/v1.0/"
      @channels = VimeoChannels.new
      @api = UChannelTool::API.new(host, logger)
      @categories = {}
      res = HttpUtil.get(@url + "video_categories", @api.getHeader)
      JSON.parse(res.body).each do |cat|
        @categories[cat["name"]] = cat["id"]
      end
    end

    def run
      channelIds = @channels.channelIds
      channelIds.each do |id|
        runOne(id)
      end
    end

    def runOne(id)
      channelName = @channels.channelName(id)
      cat_id = @categories[channelName]
      titles = {}
      res = HttpUtil.get(@url + "videos/category?id=#{cat_id}&limit=1000", @api.getHeader)
      JSON.parse(res.body)["videos"].each do |video|
        titles[video["title"]] = video["id"]
      end

      numVideos, newVids = 0, 0
      Vimeo::Simple::Channel.videos(id).each do |video|
        numVideos += 1
        next if exist?(video["id"])

        HttpUtil.post(@url + "vimeo_uploads", @api.getHeader, getInfo(video, id).to_json)
        newVids += 1

        tt, video_id = matchTitle(titles, video["title"]) 
        puts [video["title"], video_id, tt].join("\t")
        body = {
          "video_id" => video_id,
          "host" => "vimeo",
          "host_id" => video["id"]
        }.to_json

        res = HttpUtil.post(@url + "video_uploads", @api.getHeader, body) 
        raise "Failed to set video ID" if !res.kind_of? Net::HTTPSuccess

        if (video_id != -1)
          res = HttpUtil.put(@url + "video_uploads/enable", @api.getHeader, body) 
          raise "Failed to enable uploads" if !res.kind_of? Net::HTTPSuccess
        end
        break
      end
        
      puts [numVideos, newVids, id].join("\t")
    end

    def matchTitle(titles, title)
      mt = matchDates(titles, title)
      retVal, thr = ["", -1], 0
      mt.each do |key, val|
        tval, ratio = count(key, title)
        #puts [tval, ratio].join("\t")
        if tval > thr && ratio > 0.5
          retVal = [key, val]
          thr = tval
        end
      end
      retVal
    end

    def matchDates(titles, title)
      date = getDate(title)
      return titles if date.nil?
      retVal = {}
      titles.each do |key, val|
        retVal[key] = val if date == getDate(key)
      end
      retVal
    end

    def getDate(title)
      t = " " + title + " "
      return $1 if t =~ / (\d{8,}) /
      return nil 
    end

    def count(source, target)
      source = source.encode('UTF-8').each_char.to_a.uniq
      target = target.encode('UTF-8').each_char.to_a.uniq
      num = 0
      source.each do |c|
        num += 1 if target.include?(c)
      end
      return [num + source.size.to_f / target.size.to_f, num / source.size.to_f]
    end

    def getInfo(video, channel_id)
      retVal = {}
      ["duration", "title", "description", "thumbnail_small", "thumbnail_medium", "thumbnail_large", "tags",
       "width", "height", "embed_privacy"].each do |field|
        retVal[field] = video[field]
      end
      retVal["vimeo_id"] = video["id"]
      retVal["published_at"] = video["upload_date"]
      retVal["channel_id"] = channel_id
      retVal
    end

    def exist?(vimeo_id)
      return true if vimeo_id.nil?
      res = HttpUtil.get(@url + "vimeo_uploads/" + vimeo_id.to_s, @api.getHeader)
      return res.kind_of? Net::HTTPSuccess
    end 
  end
=begin
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
       "title" => info["title"].gsub("_", " ").
           gsub("UChannel 1.9", "").
           gsub("U Channel 1.9", "").
           gsub("UChannel1.9", "").
           gsub("U Channel 1 9", "").
           gsub("UChannelTV", "").
           gsub("UChennelTV", "").
           gsub("UChannel TV", "").
           gsub("UchannelTV", "").
           gsub("優視頻道", "").
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
           gsub("「親子電影站」", "").
           gsub("原創短片", "").
           gsub("原創紀錄片系列", "").
           gsub(/(^短片 )/, "").
           gsub("＿", " ").
           gsub("|", " ").
           gsub("：", " ").
           gsub(/ +/, " ").strip,
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
        return
      end

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
=end
end
