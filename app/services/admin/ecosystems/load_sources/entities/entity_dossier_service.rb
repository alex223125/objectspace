
# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        class EntityDossierService
          def initialize(entity:, relationship_limit: 100)
            @entity = entity
            @relationship_limit = relationship_limit.to_i.clamp(1, 500)
          end

          def call
            raise ArgumentError, "entity is required" unless entity

            {
              entity: entity_attributes,
              relationships: relationships,
              versions: associated_records(:versions),
              events: associated_records(:events)
            }
          end

          private

          attr_reader :entity, :relationship_limit

          def entity_attributes
            {
              id: entity.id,
              name: read_attribute(:name),
              title: read_attribute(:title),
              summary: read_attribute(:summary),
              description: read_attribute(:description),
              status: read_attribute(:status),
              created_at: read_attribute(:created_at),
              updated_at: read_attribute(:updated_at)
            }.compact
          end

          def read_attribute(attribute)
            return unless entity.respond_to?(attribute)

            entity.public_send(attribute)
          end

          def relationships
            model = relationship_model
            return [] unless model

            relation = model.all

            if model.column_names.include?("source_entity_id")
              relation = relation.where(source_entity_id: entity.id)
            elsif model.column_names.include?("entity_id")
              relation = relation.where(entity_id: entity.id)
            else
              return []
            end

            relation = relation.order(id: :desc)
            relation.limit(relationship_limit).map do |relationship|
              relationship_attributes(relationship)
            end
          end

          def relationship_model
            "Ecosystems::LoadSources::Entity::EntityRelationship"
              .safe_constantize
          end

          def relationship_attributes(relationship)
            attributes = %w[
              id source_entity_id target_entity_id
              entity_id related_entity_id relationship_type
              state confidence evidence last_discovered_at
              created_at updated_at
            ]

            attributes.each_with_object({}) do |attribute, result|
              next unless relationship.respond_to?(attribute)

              result[attribute.to_sym] =
                relationship.public_send(attribute)
            end
          end

          def associated_records(association_name)
            return [] unless entity.class.reflect_on_association(
              association_name
            )

            association = entity.public_send(association_name)
            return [] unless association.respond_to?(:limit)

            association.limit(100).to_a.map do |record|
              record.respond_to?(:attributes) ? record.attributes : record
            end
          rescue ActiveRecord::AssociationNotFoundError
            []
          end
        end
      end
    end
  end
end