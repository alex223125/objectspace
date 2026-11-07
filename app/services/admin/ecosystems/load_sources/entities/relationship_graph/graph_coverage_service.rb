# frozen_string_literal: true

# File:
# app/services/admin/ecosystems/load_sources/entities/relationship_graph/graph_coverage_service.rb

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module RelationshipGraph
          class GraphCoverageService
            def initialize(nodes:, edges:,
                           source_key: :source_entity_id,
                           target_key: :target_entity_id,
                           type_key: :entity_type_id,
                           status_key: :status)
              @nodes = normalize_records(nodes)
              @edges = normalize_records(edges)
              @source_key = source_key.to_s
              @target_key = target_key.to_s
              @type_key = type_key.to_s
              @status_key = status_key.to_s
            end

            def call
              ids = @nodes.filter_map { |node| read(node, "id") }.map(&:to_s).to_set
              connected = Set.new

              @edges.each do |edge|
                source = read(edge, @source_key)&.to_s
                target = read(edge, @target_key)&.to_s

                connected << source if source && ids.include?(source)
                connected << target if target && ids.include?(target)
              end

              type_counts = @nodes.each_with_object(Hash.new(0)) do |node, counts|
                type = read(node, @type_key)
                counts[type.nil? ? "unclassified" : type.to_s] += 1
              end

              status_counts = @nodes.each_with_object(Hash.new(0)) do |node, counts|
                status = read(node, @status_key)
                counts[status.nil? ? "unspecified" : status.to_s] += 1
              end

              {
                total_entities: @nodes.size,
                entities_with_relationships: connected.size,
                entities_without_relationships: ids.size - connected.size,
                entity_connection_coverage: percentage(connected.size, ids.size),
                entity_type_coverage: percentage(
                  @nodes.count { |node| read(node, @type_key).present? },
                  @nodes.size
                ),
                classified_entity_count: @nodes.count do |node|
                  read(node, @type_key).present?
                end,
                entity_types: type_counts.sort.to_h,
                workflow_states: status_counts.sort.to_h,
                relationship_count: @edges.size,
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
              record[key] || record[key.to_sym]
            end

            def percentage(numerator, denominator)
              return 0.0 if denominator.zero?

              (numerator.to_f / denominator * 100).round(2)
            end
          end
        end
      end
    end
  end
end