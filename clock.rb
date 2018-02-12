require "clockwork"
require_relative './config/boot'
require_relative './config/environment'

include Clockwork

every(5.seconds, "Crawl UCB") do
  UcbClassCrawler.perform_async
end

every 1.day, 'report to Mr Brett', at: '22:00' do
  UcbClassReport.perform_async
end
