class Ecosystems::LoadSources::EntityTemplates::EntityTemplateVersions::DefinitionTemplateUsage < ApplicationRecord

  self.table_name = "ecosystems_load_sources_entity_template_versions_definition_template_usages"

  belongs_to :definition_template

  belongs_to :definition_template_version,
             optional: true

  belongs_to :user,
             optional: true

  EVENT_TYPES = %w[
    viewed
    imported
    favorited
    unfavorited
    searched
    previewed
  ].freeze

  validates :event_type,
            inclusion: {
              in: EVENT_TYPES
            }

  scope :views, -> {
    where(event_type: "viewed")
  }

  scope :imports, -> {
    where(event_type: "imported")
  }

  scope :recent, -> {
    order(created_at: :desc)
  }
end