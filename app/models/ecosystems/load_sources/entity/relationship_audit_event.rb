# app/models/ecosystems/load_sources/entity/relationship_audit_event.rb
# module Ecosystems
#   module LoadSources
#     module Entity
#       class RelationshipAuditEvent < ApplicationRecord
#         self.table_name =
#           "ecosystems_load_sources_entity_relationship_audit_events"
#
#         ACTIONS = %w[confirm reject edit create archive].freeze
#
#         belongs_to :relationship,
#                    class_name: "Ecosystems::LoadSources::Entity::EntityRelationship",
#                    foreign_key: :relationship_id,
#                    optional: true
#
#         belongs_to :actor,
#                    class_name: "User",
#                    foreign_key: :actor_id,
#                    optional: true
#
#         validates :action, presence: true, inclusion: { in: ACTIONS }
#         validates :details, presence: false
#
#         scope :recent, -> { order(created_at: :desc, id: :desc) }
#         scope :for_relationship, ->(id) { where(relationship_id: id) }
#       end
#     end
#   end
# end
#
#





# frozen_string_literal: true

# app/models/ecosystems/load_sources/entity/relationship_audit_event.rb
#
# Immutable history of administrative actions performed on entity relationships.
#
# Expected table:
#   relationship_audit_events
#
# Suggested columns:
#   entity_relationship_id :bigint
#   actor_id               :bigint
#   action                 :string, null: false
#   previous_state         :string
#   new_state              :string
#   reason                 :text
#   metadata               :jsonb
#   created_at             :datetime, null: false
#   updated_at             :datetime, null: false
#
# Adjust associations to match your application's actual model names.

module Ecosystems
  module LoadSources
    module Entity
      class RelationshipAuditEvent < ApplicationRecord
        self.table_name = "ecosystems_load_sources_entity_relationship_audit_events"

        ACTIONS = %w[
          created
          updated
          submitted
          approved
          rejected
          archived
          restored
          deleted
          evidence_added
          evidence_removed
        ].freeze

        belongs_to :entity_relationship,
                   class_name: "Ecosystems::LoadSources::Entity::EntityRelationship",
                   foreign_key: :entity_relationship_id,
                   inverse_of: :relationship_audit_events

        # This association is optional because authentication systems differ.
        belongs_to :actor,
                   class_name: "User",
                   foreign_key: :actor_id,
                   optional: true

        validates :action, presence: true, inclusion: { in: ACTIONS }
        validates :reason, length: { maximum: 5_000 }, allow_nil: true

        validate :metadata_must_be_an_object

        scope :newest_first, -> { order(created_at: :desc, id: :desc) }
        scope :oldest_first, -> { order(created_at: :asc, id: :asc) }
        scope :for_action, ->(value) { where(action: value) if value.present? }

        # Create audit entries through this method rather than mass-assigning
        # arbitrary request parameters.
        def self.record!(
          relationship:,
          action:,
          actor: nil,
          previous_state: nil,
          new_state: nil,
          reason: nil,
          metadata: {}
        )
          raise ArgumentError, "relationship is required" unless relationship
          raise ArgumentError, "invalid audit action" unless ACTIONS.include?(action.to_s)

          create!(
            entity_relationship: relationship,
            actor: actor,
            action: action.to_s,
            previous_state: previous_state,
            new_state: new_state,
            reason: reason,
            metadata: sanitize_metadata(metadata)
          )
        end

        # Keep audit metadata small and avoid accepting arbitrary nested objects.
        def self.sanitize_metadata(value)
          return {} unless value.is_a?(Hash)

          permitted_keys = %w[
            source
            request_id
            changes
            evidence_id
            review_reason
            correlation_id
          ]

          value.stringify_keys.slice(*permitted_keys)
        end

        private

        def metadata_must_be_an_object
          return if metadata.nil? || metadata.is_a?(Hash)

          errors.add(:metadata, "must be a JSON object")
        end
      end
    end
  end
end