# frozen_string_literal: true

module Ecosystems
  module LoadSources
    module Entity
      module DiffIntelligence
        class IdentityExtractor
          MISSING = Object.new.freeze

          def self.call(object:, identity_key:)
            new(
              object: object,
              identity_key: identity_key
            ).call
          end

          def initialize(object:, identity_key:)
            @object = object
            @identity_key = identity_key.to_s
          end

          def call
            return MISSING unless object.is_a?(Hash)

            value =
              object[identity_key] ||
                object[identity_key.to_sym]

            return MISSING if value.nil?
            return MISSING if value.respond_to?(:empty?) && value.empty?

            value
          end

          private

          attr_reader :object,
                      :identity_key
        end
      end
    end
  end
end