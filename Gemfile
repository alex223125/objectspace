source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.1.0"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
# gem "rails", "~> 7.0.0"
gem "rails", "~> 7.0.0"

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem 'sprockets-rails', '~> 3.0', '>= 3.0.4'

# Use postgresql as the database for Active Record
gem "pg", "~> 1.5.6"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", "~> 5.0"

# Bundle and transpile JavaScript [https://github.com/rails/jsbundling-rails]
gem "jsbundling-rails"

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails", "= 1.0.0"


# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"

# Bundle and process CSS [https://github.com/rails/cssbundling-rails]
gem "cssbundling-rails"

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"

# Use Redis adapter to run Action Cable in production
gem "redis", "~> 4.0"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Use Sass to process CSS
# gem "sassc-rails"
gem 'sassc', '~> 2.1.0'

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

gem 'simple_form'

gem 'acts_as_list'

# gem 'tinymce-rails', '~> 5.10.7'

gem 'cocoon', '~> 1.2', '>= 1.2.9'

gem 'tailwindcss-rails'
gem 'jquery-rails'

gem 'pagy', '~> 6.0' # omit patch digit
gem 'pg_search', '~> 2.3', '>= 2.3.6'
# gem 'devise-security', '~> 0.17.0'
# gem 'devise-security', '~> 0.17.0'
# gem 'devise-security', git: 'git://github.com/djpremier/devise-security.git', branch: 'rails_7_0_and_ruby_3_1'
gem 'devise-security', github: 'djpremier/devise-security', branch: 'rails_7_0_and_ruby_3_1'
# gem 'email_address', '~> 0.2.4'
gem "valid_email2"


gem 'devise', '~> 4.9'
gem 'omniauth'
gem "omniauth-rails_csrf_protection"
gem "omniauth-google-oauth2"

gem 'dotenv-rails', '~> 2.1', '>= 2.1.1'

gem "breadcrumbs_on_rails"
gem 'active_enum', '~> 1.1'

# second version search bundle
gem 'searchkick'
# for searchkick
gem 'elasticsearch', '~> 7.17'

gem 'closure_tree'

gem 'acts-as-taggable-on', '~> 9.0'

gem 'friendly_id', '~> 5.4.0'

gem "actionpack-page_caching"

gem 'image_processing', '~> 1.2'
gem 'active_model_serializers', '~> 0.10.0'
gem 'sass-rails'
gem 'uuid', '~> 2.3', '>= 2.3.9'
gem 'words_counted'


group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
  gem 'pry'
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver"
  gem "webdrivers"
end
