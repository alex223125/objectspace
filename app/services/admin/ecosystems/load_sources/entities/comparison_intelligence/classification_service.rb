
# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        class ComparisonIntelligence
          class ClassificationService
            def initialize(registry: EntityFieldRegistry.new)
              @registry = registry
            end

            def call(change)
              attributes = change.to_h.deep_symbolize_keys
              path = attributes[:path].to_s
              definition = registry.fetch(path)

              before = attributes[:before]
              after = attributes[:after]

              type =
                if attributes[:type].present? &&
                  %w[added removed moved warning].include?(attributes[:type].to_s)
                  attributes[:type].to_s
                elsif before.nil?
                  "added"
                elsif after.nil?
                  "removed"
                else
                  "changed"
                end

              attributes.merge(
                type: type,
                field_type: definition[:type].to_s,
                field_label: definition[:label],
                identity_field: !!definition[:identity],
                classification: classification_for(type, definition),
                review_required: review_required?(type, definition)
              )
            end

            private

            attr_reader :registry

            def classification_for(type, definition)
              return "identity" if definition[:identity]
              return "relationship" if definition[:type].to_s.include?("relationship")
              return "content" if definition[:type] == :text
              return "structure" if definition[:type] == :structured

              type == "warning" ? "integrity" : "attribute"
            end

            def review_required?(type, definition)
              definition[:identity] ||
                %w[removed warning].include?(type)
            end
          end
        end
      end
    end
  end
end