require_relative './google_api'
require_relative './http_util'
require 'time'

module YoutubeTools
  class VideoCollector
    def initialize(host, logger)
      @url = "http://#{host}/api/v1.0/youtube_uploads/"
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
      res = HttpUtil.get(@url + youtube_id, {})
      return res.kind_of? Net::HTTPSuccess
    end
  end
end
