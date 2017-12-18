require 'twitter'

#https://github.com/sferik/twitter/blob/master/examples/Update.md
 
client = Twitter::REST::Client.new do |config|
  config.consumer_key        = "Xoh95G31SblnB1FBULCgC0BAm"
  config.consumer_secret     = "dkVd4bSz1X11r6OzLMBMhoz6YhE8RS6oiqCmz0YmRPrCgHOKXd"
  config.access_token        = "938659642539782144-EaZikn58QOQpQLcQzlpC29m99nuQPqU"
  config.access_token_secret = "ADzOsjqGWOFZIBomraHhFT8OFzGjiHlFKhjuvaS8t3FCb"
end

#client.update("Test message from API")

client.update_with_media("Test tweeting with images", File.new("/Users/guoning.hu/Downloads/uchannel-tv-logo-update-v2.jpg"))

