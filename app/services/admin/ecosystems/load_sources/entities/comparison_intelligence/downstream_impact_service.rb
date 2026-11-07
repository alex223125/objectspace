
# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        class ComparisonIntelligence
          class DownstreamImpactService
            def call(changes:, relationships:)
              changed_ids = Array(changes).filter_map do |change|
                attributes = change.to_h.stringify_keys
                attributes["entity_id"] || attributes["target_id"]
              end.map(&:to_s).to_set

              edges = Array(relationships).map do |relationship|
                relationship.to_h.stringify_keys
              end

              affected = edges.select do |edge|
                changed_ids.include?(edge["source_id"].to_s) ||
                  changed_ids.include?(edge["target_id"].to_s)
              end

              nodes = affected.flat_map do |edge|
                [edge["source_id"], edge["target_id"]]
              end.compact.map(&:to_s).uniq

              {
                directly_changed_entities: changed_ids.length,
                affected_relationships: affected.length,
                affected_entity_ids: nodes,
                affected_entity_count: nodes.length,
                relationships: affected,
                requires_review: affected.any?
              }
            end
          end
        end
      end
    end
  end
end