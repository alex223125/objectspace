require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Objectspace
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    config.autoloader = :classic

    Dir[Rails.root.join('app/services/**/*.rb')].each{|rb| require rb}
    Dir[Rails.root.join('app/services/concerns/**/*.rb')].each{|rb| require rb}
    Dir[Rails.root.join('app/services/simple_classes/simple_classes/*.rb')].each{|rb| require rb}
    Dir[Rails.root.join('app/builders/**/*.rb')].each{|rb| require rb}
    Dir[Rails.root.join('app/enums/**/*.rb')].each{|rb| require rb}
    Dir[Rails.root.join('app/queries/**/*.rb')].each{|rb| require rb}
    Dir[Rails.root.join('app/serializers/**/*.rb')].each{|rb| require rb}
    Dir[Rails.root.join('app/forms/**/*.rb')].each{|rb| require rb}


    # Add this line to bypass the Zeitwerk name checking error:
    Rails.autoloaders.main.ignore(Rails.root.join("app/controllers/not_in_use"))
    Rails.autoloaders.main.ignore(Rails.root.join("app/controllers/was"))
    Rails.autoloaders.main.ignore(Rails.root.join("app/controllers/algorithm/not_in_use"))
    Rails.autoloaders.main.ignore(Rails.root.join("app/controllers/cheat_sheet/not_in_use"))
    Rails.autoloaders.main.ignore(Rails.root.join("app/controllers/cheat_sheet_group/not_in_use/"))

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    config.i18n.default_locale = :en

    config.assets.paths << Rails.root.join('node_modules')

    config.active_storage.variant_processor = :mini_magick



    # config.assets.paths << Rails.root.join('node_modules')

    # config.tinymce.install = :copy
    # config.tinymce.install = :compile

  end
end
