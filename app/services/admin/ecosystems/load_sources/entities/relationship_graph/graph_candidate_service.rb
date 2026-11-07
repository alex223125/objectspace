# frozen_string_literal: true

# File:
# app/services/admin/ecosystems/load_sources/entities/relationship_graph/graph_candidate_service.rb

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module RelationshipGraph
          class GraphCandidateService
            DEFAULT_MATCH_FIELDS = %w[entity_type_id slug].freeze

            def initialize(nodes:, edges:,
                           match_fields: DEFAULT_MATCH_FIELDS,
                           source_key: :source_entity_id,
                           target_key: :target_entity_id,
                           minimum_shared_fields: 1,
                           limit: 50)
              @nodes = normalize_records(nodes)
              @edges = normalize_records(edges)
              @match_fields = Array(match_fields).map(&:to_s)
              @source_key = source_key.to_s
              @target_key = target_key.to_s
              @minimum_shared_fields = [minimum_shared_fields.to_i, 1].max
              @limit = [[limit.to_i, 1].max, 200].min
            end

            def call
              existing_pairs = @edges.filter_map do |edge|
                source = read(edge, @source_key)&.to_s
                target = read(edge, @target_key)&.to_s
                next if source.blank? || target.blank?

                [source, target].sort
              end.to_set

              candidates = []

              @nodes.combination(2) do |left, right|
                left_id = read(left, "id")&.to_s
                right_id = read(right, "id")&.to_s

                next if left_id.blank? || right_id.blank? || left_id == right_id
                next if existing_pairs.include?([left_id, right_id].sort)

                shared = shared_fields(left, right)
                next if shared.size < @minimum_shared_fields

                candidates << {
                  source: entity_summary(left),
                  target: entity_summary(right),
                  shared_fields: shared,
                  confidence: confidence(shared.size),
                  status: "suggested",
                  requires_review: true
                }
              end

              {
                candidates: candidates.sort_by { |candidate| -candidate[:confidence] }
                                      .first(@limit),
                candidate_count: candidates.size,
                truncated: candidates.size > @limit,
                generated_at: Time.current.iso8601
              }
            end

            private

            def normalize_records(records)
              Array(records).map do |record|
                record.respond_to?(:attributes) ? record.attributes : record.to_h.stringify_keys
              end
            end

            def read(record, key)
              record[key.to_s] || record[key.to_sym]
            end

            def shared_fields(left, right)
              @match_fields.filter_map do |field|
                left_value = read(left, field)
                right_value = read(right, field)

                next if left_value.blank? || right_value.blank?
                next unless left_value.to_s.casecmp?(right_value.to_s)

                field
              end
            end

            def entity_summary(record)
              {
                id: read(record, "id").to_s,
                name: read(record, "name").to_s,
                entity_type_id: read(record, "entity_type_id")
              }
            end

            def confidence(shared_count)
              [shared_count.to_f / [@match_fields.size, 1].max, 1.0].min.round(2)
            end
          end
        end
      end
    end
  end
end