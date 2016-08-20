require 'json'
require 'time'
require_relative './http_util'

module GoogleAPI
  include HttpUtil

  class Auth
    def self.getToken(cache, logger)
      t = Time.now.to_i
      token = cache.read("google_token")
      if token.nil? || token[1] <= t
        val, exp = refreshToken(logger)
        return nil if val.nil?
        token = [val, t + exp - 60]
        cache.write("google_token", token)
      end
      return token[0]
    end

    def self.refreshToken(logger)
      logger.debug("Refresh Google API token")
      url = "https://www.googleapis.com/oauth2/v4/token"
      header = {'Content-Type' => 'application/x-www-form-urlencoded'}
      body = "client_id=#{ENV["GOOGLE_API_CLIENT_ID"]}&client_secret=#{ENV['GOOGLE_API_CLIENT_SECRET']}&" +
          "refresh_token=#{ENV['GOOGLE_API_REFRESH_TOKEN']}&grant_type=refresh_token"
      res = HttpUtil.https_post(url, header, body)
      if res.kind_of? Net::HTTPSuccess
        info = JSON.parse(res.body)
        return [info["access_token"], info["expires_in"]]
      end
      
      logger.error("Fail to refresh Google API token, error code " + res.code)
      logger.debug(res.body)
      return [nil, nil]
    end
  end

  class YoutubeAPI
    @@url = "https://www.googleapis.com/youtube/v3/"
    def self.getVideoIds(playListId, token, pageToken, logger)
      url = @@url + "playlistItems?part=contentDetails&maxResults=50&order=date&playlistId=" + playListId
      url += "&pageToken=" + pageToken if !pageToken.nil?
      logger.debug("Collect youtube video " + url)
      header = {'Authorization' => 'Bearer ' + token}
      res = HttpUtil.https_get(url, header)
      if res.kind_of? Net::HTTPSuccess
        info = JSON.parse(res.body)
        pageToken = info["nextPageToken"]
        videos = []
        info["items"].each do |item|
          videos << item["contentDetails"]["videoId"]
        end
        return [videos, pageToken] 
      end

      logger.error("Fail to collect youtube video, error code " + res.code)
      logger.debug(res.body)
      return [nil, nil]
    end

    def self.searchUChannelVideo(playListId, token, pageToken, before, logger)
      url = "https://www.googleapis.com/youtube/v3/search?part=snippet&channelId=#{playListId}&maxResults=50"
      url += "&pageToken=" + pageToken if !pageToken.nil?
      url += "&publishedBefore=" + before.gsub(":", "%3A") if !before.nil?
      #logger.debug("Search youtube video " + url)
      header = {'Authorization' => 'Bearer ' + token}
      res = HttpUtil.https_get(url, header)
      if res.kind_of? Net::HTTPSuccess
        info = JSON.parse(res.body)
        pageToken = info["nextPageToken"]
        videos = []
        info["items"].each do |item|
          videos << item["id"]["videoId"]
        end
        return [videos, pageToken] 
      end

      logger.error("Fail to search youtube video, error code " + res.code)
      logger.debug(res.body)
      return [nil, nil]
    end

    def self.getVideoInfo(token, vids, logger)
      retVal = {}
      snippets = getVideoPart(token, "snippet", vids, logger)
      return nil if snippets.nil?
      snippets["items"].each do |item|
        id, snippet = item["id"], item["snippet"]
        retVal[id] = {"youtube_id" => id,
                      "published_at" => snippet["publishedAt"],
                      "title" => snippet["title"],
                      "description" => snippet["description"],
                      "thumbnail_small" => snippet["thumbnails"]["default"]["url"],
                      "thumbnail_medium" => snippet["thumbnails"]["medium"]["url"],
                      "thumbnail_large" => snippet["thumbnails"]["high"]["url"],
                      "live_broadcast_content" => snippet["liveBroadcastContent"],
                      "tags" => snippet["tags"],
                      "category_id" => snippet["categoryId"]
        }
      end

      contentDetails = getVideoPart(token, "contentDetails", vids, logger)
      return nil if contentDetails.nil?
      contentDetails["items"].each do |item|
        retVal[item["id"]]["duration"] = parseDuration(item["contentDetails"]["duration"])
      end

      vStates = getVideoPart(token, "status", vids, logger)
      return nil if vStates.nil?
      vStates["items"].each do |item|
        id, status = item["id"], item["status"]
        retVal[id]["upload_status"] = status["uploadStatus"]
        retVal[id]["privacy_status"] = status["privacyStatus"]
        retVal[id]["embeddable"] = status["embeddable"]
      end

      return retVal
    end

    def self.getVideoPart(token, part, vids, logger)
      vidStr = vids.join(",")
      url = "https://www.googleapis.com/youtube/v3/videos?part=#{part}&id=" + vidStr
      #logger.debug("Get youtube video #{part} " + url)
      header = {'Authorization' => 'Bearer ' + token,
                'Content-Type' => 'application/x-www-form-urlencoded'}
      res = HttpUtil.https_get(url, header)
      return JSON.parse(res.body) if res.kind_of? Net::HTTPSuccess

      logger.error("Fail to get youtube video #{part}, error code " + res.code)
      logger.debug(res.body)
      return nil
    end

    def self.parseDuration(dur)
      dStr = dur.gsub("PT", "1970-01-01 ")
      pattern = "%Y-%m-%d "
      pattern += "%HH" if dur.include? "H"
      pattern += "%MM" if dur.include? "M"
      pattern += "%SS" if dur.include? "S"
      DateTime.strptime(dStr, pattern).to_time.to_i
    end
  end

end
