require 'json'
require 'time'
require_relative './http_util'

module UChannelTool
  include HttpUtil

=begin
  class Auth
    def self.getToken(cache, logger)
      t = Time.now.to_i
      token = cache.read("uchannel_token")
      if token.nil? || token[1] <= t
        val, exp = refreshToken(logger)
        return nil if val.nil?
        token = [val, t + exp - 60]
        cache.write("uchannel_token", token)
      end
      return token[0]
    end

    def self.refreshToken(host, logger)
      logger.debug("Refresh UChannel API token")
      url = "http://#{host}/oauth/token"
      puts url
      header = {'Content-Type' => 'application/x-www-form-urlencoded'}
      body = "client_id=#{ENV["UCHANNEL_API_CLIENT_ID"]}&client_secret=#{ENV['UCHANNEL_API_CLIENT_SECRET']}&" +
          "grant_type=refresh_token&refresh_token=#{ENV['UCHANNEL_API_REFRESH_TOKEN']}"
      puts body
      res = HttpUtil.post(url, header, body)
      puts res.body
      if res.kind_of? Net::HTTPSuccess
        info = JSON.parse(res.body)
        return [info["access_token"], info["expires_in"]]
      end
      
      logger.error("Fail to refresh UChannel API token, error code " + res.code)
      logger.debug(res.body)
      return [nil, nil]
    end
  end
=end
  class API
    def initialize(host, logger)
      @host, @logger, @token = host, logger, ENV["UCHANNEL_API_ACCESS_TOKEN"] 
      #@host, @logger, @token, @expired_at = host, logger, nil, 0
    end
=begin
    def updateToken
      t = Time.now.to_i
      
      if @token.nil? || @expired_at <= t
        @token, exp = Auth.refreshToken(@host, @logger)
        @expired_at = t + exp - 60 if !@token.nil?
      end
    end
=end
    def getHeader
      #updateToken
      {'Content-Type' => 'application/json', 'Authorization' => 'Bearer ' + @token}
    end
  end

  class Content
    def self.normalizeTitle(title, category)
      title.gsub("_", " ").
           gsub("UChannel 1.9", "").
           gsub("U Channel 1.9", "").
           gsub("UChannel1.9", "").
           gsub("U Channel 1 9", "").
           gsub("U ChannelTV", "").
           gsub("UChannelTV", "").
           gsub("UChennelTV", "").
           gsub("UChannel TV", "").
           gsub("UchannelTV", "").
           gsub("優視頻道", "").
           gsub("優視" + category, "").
           gsub("FocusNews", "").
           gsub("Focus News", "").
           gsub("焦點話題", "").
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
           gsub("理財妙管家", "").
           gsub(" U16 ", " ").
           gsub(" HD ", " ").
           gsub(/ HD$/, "").
           gsub("_", " ").
           gsub("＿", " ").
           gsub("|", " ").
           gsub("：", " ").
           gsub(/ +/, " ").strip
    end
  end
end
