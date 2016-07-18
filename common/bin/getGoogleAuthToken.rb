require 'logger'
require_relative '../lib/google_api'

logger = Logger.new(STDOUT)
puts GoogleAPI::Auth.refreshToken(logger)[0]
