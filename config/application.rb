require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "sprockets/railtie"

Bundler.require(:default, Rails.env)

module Zarafadashboard
  class Application < Rails::Application
    config.time_zone = 'Central Time (US & Canada)'
    config.i18n.default_locale = :de
  end
end
