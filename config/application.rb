require_relative 'boot'

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_cable/engine"
# require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Brettbot
  class Application < Rails::Application
    Bundler.require(*Rails.groups)

    Capybara.current_driver = :webkit
    Capybara.app_host = 'https://newyork.ucbtrainingcenter.com'
    Rails.instance_variable_set(:@capybara_session, Capybara::Session.new(:webkit, Rails.application))

    Dotenv.load

    require "capybara/rails"
    Capybara.current_driver = :webkit
    Capybara.app_host = 'https://newyork.ucbtrainingcenter.com'
    Rails.instance_variable_set(:@capybara_session, Capybara::Session.new(:webkit, Rails.application))

    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Don't generate system test files.
    config.generators.system_tests = nil
  end
end

module Enumerable
  def count_by(&block)
    Hash[group_by(&block).map { |key,vals| [key, vals.size] }]
  end
end

Time.zone = "EST"
EST       = Time.zone
PT        = ActiveSupport::TimeZone.new("America/Los_Angeles")
UTC       = ActiveSupport::TimeZone.new("UTC")
