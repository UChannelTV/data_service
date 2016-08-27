require 'net/http'
require 'uri'

module HttpUtil
  def self.initHttp(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true if uri.scheme == 'https'
    return http
  end

  def self.post(url, header, body)
    uri = URI.parse(url)
    http = initHttp(uri)
    req = Net::HTTP::Post.new(uri, initheader = header)
    req.body = body
    return http.request(req)
  end

  def self.get(url, header)
    uri = URI.parse(url)
    http = initHttp(uri)
    req = Net::HTTP::Get.new(uri, initheader = header)
    return http.request(req)
  end

  def self.put(url, header, body)
    uri = URI.parse(url)
    http = initHttp(uri)
    req = Net::HTTP::Put.new(uri, initheader = header)
    req.body = body
    return http.request(req)
  end
end
