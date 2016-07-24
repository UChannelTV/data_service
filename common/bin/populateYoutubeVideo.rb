require 'logger'
require_relative '../lib/youtube_tools'
require 'json'

logger = Logger.new(STDOUT)
collector = YoutubeTools::VideoConverter.new(ARGV[0], logger)
collector.run(10)


