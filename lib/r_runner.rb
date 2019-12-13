require 'mumukit'
require 'nokogiri'

Mumukit.runner_name = 'r'
Mumukit.configure do |config|
  config.docker_image = 'mumuki/mumuki-r-worker:0.1'
  config.structured = true
  config.stateful = true
end

require_relative './version'
require_relative './metadata_hook'
require_relative './test_hook'
require_relative './query_hook'
require_relative './try_hook'
