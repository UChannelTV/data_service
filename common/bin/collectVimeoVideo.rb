require 'logger'
require_relative '../lib/vimeo_tools'
require 'json'

logger = Logger.new(STDOUT)
collector = VimeoTools::VideoCollector.new(ARGV[0], logger)
collector.run


