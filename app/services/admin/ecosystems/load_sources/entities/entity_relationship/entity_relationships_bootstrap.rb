# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module EntityRelationship
          class EntityRelationshipsBootstrap

            def initialize(
              limit: 100,
              per_entity: 10
            )
              @limit = limit.to_i.clamp(1, 10_000)
              @per_entity = per_entity.to_i.clamp(1, 50)
            end

            def call
              processed = 0

              entity_scope.find_each(
                batch_size: 100
              ) do |entity|

                break if processed >= @limit

                EntityRelationshipDiscovery
                  .new(
                    entity: entity,
                    limit: @per_entity
                  )
                  .call

                processed += 1
              end

              processed
            end

            private

            def entity_scope
              Entity::Entity
                .where.not(
                entity_type_id: nil
              )
                .where.not(
                entity_template_id: nil
              )
            end

          end
        end
      end
    end
  end
end