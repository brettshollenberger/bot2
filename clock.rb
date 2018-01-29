require "clockwork"
require_relative './config/boot'
require_relative './config/environment'

include Clockwork

every(15.seconds, "Crawl UCB") do
  UcbClassCrawler.perform_async
end
