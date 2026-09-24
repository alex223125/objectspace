# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module EntitiesHelper

        def json_value(value)
          JSON.pretty_generate(value)
        rescue StandardError
          value.to_s
        end

      end
    end
  end
end