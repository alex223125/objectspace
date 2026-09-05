module Ecosystems
  module LoadSources
    module EntityTemplates
      class EntityTemplateField < ApplicationRecord
        self.table_name = "ecosystems_load_sources_entity_template_fields"

        FIELD_TYPES = %w[
        text
        textarea
        rich_text
        integer
        decimal
        boolean
        date
        datetime
        select
        multiselect
        entity_reference
        url
        email
      ].freeze

        belongs_to :entity_template_version,
                   class_name: "Ecosystems::LoadSources::EntityTemplateVersion"

        validates :name, presence: true
        validates :slug, presence: true
        validates :label, presence: true
        validates :field_type, presence: true,
                  inclusion: { in: FIELD_TYPES }

        validates :slug,
                  uniqueness: {
                    scope: :entity_template_version_id
                  }

        validates :position,
                  numericality: {
                    only_integer: true,
                    greater_than_or_equal_to: 0
                  }

        scope :active, -> { where(active: true) }
        scope :ordered, -> { order(:position) }

        before_validation :generate_slug, if: -> { slug.blank? && name.present? }

        private

        def generate_slug
          self.slug = name.to_s.parameterize(separator: "_")
        end
      end
    end
  end
end