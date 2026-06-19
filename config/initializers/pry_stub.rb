# config/initializers/pry_stub.rb
unless Rails.env.development? || Rails.env.test?
  module Kernel
    def pry(*args)
      Rails.logger.warn "⚠️ Blocked a binding.pry call at: #{caller.first}"
    end
  end
end