require 'logger'
require_relative '../lib/google_api'
require_relative '../lib/youtube_tools'
require 'json'

stopIfNoNew = ARGV[0].to_i > 0
logger = Logger.new(STDOUT)
collector = YoutubeTools::VideoCollector.new(ARGV[1], logger)
collector.run(stopIfNoNew)


