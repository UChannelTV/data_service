require 'json'
require 'time'
require_relative './http_util'

module UChannelAPI
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
end
