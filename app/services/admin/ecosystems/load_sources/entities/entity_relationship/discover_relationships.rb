# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module EntityRelationship
          class DiscoverRelationships
            DEFAULT_BATCH_SIZE = 100

            def initialize(
              entity_scope: nil,
              batch_size: DEFAULT_BATCH_SIZE
            )
              @entity_scope =
                entity_scope ||
                  EntityModel
                    .where.not(status: "archived")
                    .where.not(status: "deprecated")

              @batch_size = batch_size
            end

            def call
              processed = 0

              entity_scope.find_in_batches(
                batch_size: batch_size
              ) do |batch|

                batch.each do |entity|
                  RelationshipDiscovery
                    .new(entity)
                    .call

                  processed += 1
                end
              end

              {
                processed_entities: processed,
                relationships:
                  RelationshipModel.count
              }
            end

            private

            attr_reader :entity_scope, :batch_size

            def EntityModel
              Ecosystems::LoadSources::Entity::Entity
            end

            def RelationshipModel
              Ecosystems::LoadSources::Entity::EntityRelationship
            end
          end
        end
      end
    end
  end
end