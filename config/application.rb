require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Objectspace
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    Dir[Rails.root.join('app/services/**/*.rb')].each{|rb| require rb}
    Dir[Rails.root.join('app/services/simple_classes/simple_classes/*.rb')].each{|rb| require rb}
    Dir[Rails.root.join('app/builders/**/*.rb')].each{|rb| require rb}
    Dir[Rails.root.join('app/enums/**/*.rb')].each{|rb| require rb}
    Dir[Rails.root.join('app/queries/**/*.rb')].each{|rb| require rb}
    Dir[Rails.root.join('app/serializers/**/*.rb')].each{|rb| require rb}

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    config.i18n.default_locale = :en
  end
end
