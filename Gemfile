source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'rails', '~> 5.1.4'
gem 'pg', '~> 0.18'
gem 'puma', '~> 3.7'
gem 'webpacker'
gem 'jbuilder', '~> 2.5'
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
gem 'sidekiq'
gem 'clockwork'
gem 'foreman'
gem 'httparty'
gem 'chronic'
gem 'tickle', git: "https://github.com/yb66/tickle", ref: "f5e69481ee7b2d8ec2057ad62f32703d2e6968f5"
gem 'historiographer', path: 'dependencies/historiographer', require: 'historiographer'
gem 'devise'
gem 'sendgrid-ruby'
gem 'capybara'
gem 'selenium-webdriver'
gem 'capybara-webkit'
gem 'twilio-ruby', '~> 5.6.1'
gem 'dotenv-rails'

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'pry'
end

group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end
