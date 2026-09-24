# app/models/ecosystems/load_sources/entity/entity_editorial_comment.rb

# frozen_string_literal: true

module Ecosystems
  module LoadSources
    module Entity

      class EntityEditorialComment < ApplicationRecord

        self.table_name =
          "ecosystems_load_sources_entity_editorial_comments"

        COMMENT_TYPES = {
          comment: "comment",
          review: "review",
          change_request: "change_request",
          approval: "approval",
          rejection: "rejection",
          system: "system"
        }.freeze

        belongs_to :entity,
                   class_name:
                     "Ecosystems::LoadSources::Entity::Entity"

        belongs_to :author,
                   class_name: "User"

        belongs_to :entity_version,
                   class_name:
                     "Ecosystems::LoadSources::Entity::EntityVersion",
                   optional: true

        validates :body,
                  presence: true

        validates :comment_type,
                  presence: true,
                  inclusion: {
                    in: COMMENT_TYPES.values
                  }

        scope :chronological,
              -> { order(created_at: :asc) }

        scope :newest_first,
              -> { order(created_at: :desc) }

        def self.type_for(value)
          COMMENT_TYPES.fetch(value.to_sym)
        end

        def self.create_comment!(
          entity:,
          author:,
          body:,
          comment_type: :comment,
          entity_version: nil
        )
          create!(
            entity: entity,
            author: author,
            body: body,
            comment_type: type_for(comment_type),
            entity_version: entity_version
          )
        end

      end

    end
  end
end