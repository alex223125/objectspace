# frozen_string_literal: true

module Admin
  module Ecosystem
    module LoadSources
      module Entities
        module Discovery
          class EntityAdapter
            ASSOCIATION_GROUPS = {
              "problem" => %i[problems problem],
              "method" => %i[methods method],
              "algorithm" => %i[algorithms algorithm],
              "technology" => %i[technologies technology],
              "entity" => %i[related_entities related_entities_as_source related_entities_as_target],
              "version" => %i[versions]
            }.freeze

            def initialize(entity)
              @entity = entity
            end

            def neighbors
              results = []

              association_candidates.each do |association_name|
                records = safe_association_records(association_name)

                records.each do |record|
                  next if record.blank?
                  next if same_record?(record)

                  results << normalize(record, association_name)
                end
              end

              results
                .uniq { |item| [item[:type], item[:id]] }
            end

            def relationship_records
              return [] unless entity.respond_to?(:relationships)

              value = entity.public_send(:relationships)

              if value.respond_to?(:to_a)
                value.to_a
              else
                Array(value)
              end
            rescue StandardError
              []
            end

            def relationship_neighbors
              relationship_records.filter_map do |relationship|
                extract_relationship_neighbor(relationship)
              end
            end

            private

            attr_reader :entity

            def association_candidates
              names = ASSOCIATION_GROUPS.values.flatten

              names.select do |association_name|
                entity.respond_to?(association_name)
              end
            end

            def safe_association_records(name)
              value = entity.public_send(name)

              if value.respond_to?(:to_a)
                value.to_a
              elsif value.present?
                Array(value)
              else
                []
              end
            rescue StandardError
              []
            end

            def same_record?(record)
              record.class == entity.class && record.id.to_s == entity.id.to_s
            end

            def normalize(record, source_association)
              {
                id: record.id,
                type: normalize_type(record, source_association),
                name: display_name(record),
                record: record,
                source: "association",
                association: source_association.to_s,
                confidence: association_confidence(source_association)
              }
            end

            def extract_relationship_neighbor(relationship)
              candidates = %i[target_entity source_entity target source related_entity entity]

              candidates.each do |attribute|
                next unless relationship.respond_to?(attribute)

                candidate = relationship.public_send(attribute)
                next if candidate.blank?
                next if same_record?(candidate)

                return {
                  id: candidate.id,
                  type: candidate.class.name.demodulize.underscore,
                  name: display_name(candidate),
                  record: candidate,
                  source: "relationship",
                  relationship_kind: relationship_kind(relationship),
                  confidence: relationship_confidence(relationship)
                }
              end

              nil
            rescue StandardError
              nil
            end

            def normalize_type(record, association)
              association.to_s
                         .singularize
                         .underscore
                         .presence ||
                record.class.name.demodulize.underscore
            end

            def display_name(record)
              %i[name title label display_name].each do |attribute|
                next unless record.respond_to?(attribute)

                value = record.public_send(attribute)
                return value.to_s if value.present?
              end

              "#{record.class.name.demodulize} ##{record.id}"
            end

            def association_confidence(association)
              case association.to_s
              when "related_entities", "relationships"
                0.95
              when "methods", "algorithms", "technologies", "problems"
                0.85
              when "versions"
                0.70
              else
                0.60
              end
            end

            def relationship_kind(relationship)
              return relationship.relationship_kind.to_s if relationship.respond_to?(:relationship_kind)
              return relationship.kind.to_s if relationship.respond_to?(:kind)
              return relationship.relation_type.to_s if relationship.respond_to?(:relation_type)

              "related"
            end

            def relationship_confidence(relationship)
              return relationship.confidence.to_f if relationship.respond_to?(:confidence) &&
                relationship.confidence.present?

              0.90
            end
          end
        end
      end
    end
  end
end
