require "clockwork"
require_relative './config/boot'
require_relative './config/environment'

include Clockwork

every(5.seconds, "Crawl UCB") do
  UcbClassCrawler.perform_async
end

every 6.hours, 'report to Mr Brett' do
  UcbClassReport.perform_async
end
