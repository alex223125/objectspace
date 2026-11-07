require "digest"
require "json"

# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        class ComparisonIntelligence
          class RelationshipDiffService
            IDENTITY_FIELDS = %w[
              id relationship_id target_id entity_id
              target_entity_id slug key
            ].freeze

            def call(before:, after:, path: "relationships")
              old_items = normalize_items(before)
              new_items = normalize_items(after)

              old_map = index_items(old_items)
              new_map = index_items(new_items)

              (old_map.keys | new_map.keys).sort.flat_map do |identity|
                old_item = old_map[identity]
                new_item = new_map[identity]

                if old_item.nil?
                  [entry(path, identity, "added", nil, new_item)]
                elsif new_item.nil?
                  [entry(path, identity, "removed", old_item, nil)]
                elsif old_item != new_item
                  [entry(path, identity, "changed", old_item, new_item)]
                else
                  []
                end
              end
            end

            private

            def normalize_items(value)
              items =
                case value
                when nil then []
                when Array then value
                when Hash then value.map { |key, item| item.is_a?(Hash) ? item.merge("key" => key) : { "key" => key, "value" => item } }
                else [{ "value" => value }]
                end

              items.map do |item|
                item.respond_to?(:to_h) ? item.to_h.stringify_keys : { "value" => item }
              end
            end

            def index_items(items)
              items.each_with_object({}) do |item, result|
                identity = identity_for(item)
                result[identity] = item
              end
            end

            def identity_for(item)
              field = IDENTITY_FIELDS.find { |key| item[key].present? }

              return "#{field}:#{item[field]}" if field

              Digest::SHA256.hexdigest(
                JSON.generate(item.sort.to_h)
              )
            end

            def entry(path, identity, type, before, after)
              {
                path: "#{path}[#{identity}]",
                relationship_identity: identity,
                type: type,
                before: before,
                after: after
              }
            end
          end
        end
      end
    end
  end
end