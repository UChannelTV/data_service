require 'logger'
require_relative '../lib/uchannel_api'

logger = Logger.new(STDOUT)
puts UChannelAPI::Auth.refreshToken(ARGV[0], logger)[0]
