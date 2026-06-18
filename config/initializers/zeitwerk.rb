# config/initializers/zeitwerk.rb

# 1. Explicitly define the top-level module container
module Services; end

# 2. Tell the main loader that app/services maps directly to the Services module namespace
Rails.autoloaders.main.push_dir("#{Rails.root}/app/services", namespace: Services)

# 3. Prevent Rails from treating app/services as a default flat folder
ActiveSupport::Dependencies.autoload_paths.delete("#{Rails.root}/app/services")
