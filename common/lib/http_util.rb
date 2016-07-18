require 'net/http'
require 'uri'

module HttpUtil
  def self.initHttp(uri, use_ssl)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true if use_ssl
    return http
  end

  def self.post(url, header, body, use_ssl=false)
    uri = URI.parse(url)
    http = initHttp(uri, use_ssl)
    req = Net::HTTP::Post.new(uri, initheader = header)
    req.body = body
    return http.request(req)
  end

  def self.https_post(url, header, body)
    return post(url, header, body, true)
  end

  def self.get(url, header, use_ssl=false)
    uri = URI.parse(url)
    http = initHttp(uri, use_ssl)
    req = Net::HTTP::Get.new(uri, initheader = header)
    return http.request(req)
  end

  def self.https_get(url, header)
    return get(url, header, true)
  end
end
