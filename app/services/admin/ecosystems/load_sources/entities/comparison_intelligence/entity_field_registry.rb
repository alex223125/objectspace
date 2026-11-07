
# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        class ComparisonIntelligence
          class EntityFieldRegistry
            DEFAULT_DEFINITIONS = {
              "name" => { type: :text, label: "Name", identity: true },
              "title" => { type: :text, label: "Title" },
              "slug" => { type: :identifier, label: "Slug", identity: true },
              "description" => { type: :text, label: "Description" },
              "summary" => { type: :text, label: "Summary" },
              "status" => { type: :categorical, label: "Status" },
              "parent_id" => { type: :relationship, label: "Parent entity" },
              "entity_type" => { type: :categorical, label: "Entity type" },
              "tags" => { type: :structured, label: "Tags" },
              "aliases" => { type: :structured, label: "Aliases" },
              "relationships" => { type: :relationship_collection, label: "Relationships" },
              "sources" => { type: :structured, label: "Sources" },
              "references" => { type: :structured, label: "References" },
              "metadata" => { type: :structured, label: "Metadata" }
            }.freeze

            def initialize(definitions: {})
              @definitions = DEFAULT_DEFINITIONS.merge(
                normalize_definitions(definitions)
              )
            end

            def fetch(path)
              key = path.to_s
              exact = definitions[key]
              return exact if exact

              parent_path = key.split(".").first
              definitions[parent_path] || {
                type: infer_type(key),
                label: humanize(key),
                identity: false
              }
            end

            def identity_field?(path)
              !!fetch(path)[:identity]
            end

            def comparable?(path)
              !%w[id created_at updated_at lock_version].include?(path.to_s)
            end

            def paths
              definitions.keys
            end

            private

            attr_reader :definitions

            def normalize_definitions(value)
              value.to_h.each_with_object({}) do |(key, definition), result|
                result[key.to_s] = definition.to_h.symbolize_keys
              end
            end

            def infer_type(path)
              key = path.to_s.downcase

              return :relationship if key.end_with?("_id")
              return :text if key.match?(/description|summary|content|body|text/)
              return :structured if key.match?(/metadata|settings|config|attributes/)
              return :categorical if key.match?(/status|state|type|category/)

              :scalar
            end

            def humanize(path)
              path.to_s.split(".").last.to_s
                  .tr("_", " ")
                  .capitalize
            end
          end
        end
      end
    end
  end
end