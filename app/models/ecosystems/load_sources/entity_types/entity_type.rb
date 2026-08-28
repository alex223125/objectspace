module Ecosystems
  module LoadSources
    module EntityTypes
      class EntityType < ApplicationRecord
        self.table_name = "ecosystems_load_sources_entity_types"

        searchkick

        belongs_to :parent,
                   class_name: "Ecosystems::LoadSources::EntityTypes::EntityType",
                   optional: true

        has_many :children,
                 class_name: "Ecosystems::LoadSources::EntityTypes::EntityType",
                 foreign_key: :parent_id,
                 dependent: :restrict_with_error

        validates :name, presence: true
        validates :slug, presence: true,
                  uniqueness: true

        scope :active, -> { where(active: true) }
        scope :root_types, -> { where(parent_id: nil) }

        before_validation :generate_slug, if: -> { slug.blank? }

        def root?
          parent_id.nil?
        end

        def leaf?
          children.none?
        end

        private

        def generate_slug
          self.slug = name.to_s.parameterize
        end
      end
    end
  end
end
