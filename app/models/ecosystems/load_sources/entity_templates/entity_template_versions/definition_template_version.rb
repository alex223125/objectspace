# frozen_string_literal: true

class Ecosystems::LoadSources::EntityTemplates::EntityTemplateVersions::DefinitionTemplateVersion < ApplicationRecord
  self.table_name = "ecosystems_load_sources_entity_template_definition_versions"

  belongs_to :definition_template,
             class_name: "Ecosystems::LoadSources::EntityTemplates::EntityTemplateVersions::DefinitionTemplate",
             foreign_key: :definition_template_id

  validates :version,
            presence: true,
            numericality: {
              only_integer: true,
              greater_than: 0
            }

  validates :status,
            inclusion: {
              in: %w[draft published archived]
            }

  validates :definition,
            presence: true

  scope :draft, -> {
    where(status: "draft")
  }

  scope :published, -> {
    where(status: "published")
  }

  scope :archived, -> {
    where(status: "archived")
  }

  scope :newest, -> {
    order(version: :desc)
  }

  def fields
    Array(definition&.fetch("fields", []))
  end

  def field_count
    fields.length
  end

  def required_field_count
    fields.count do |field|
      field["required"] == true
    end
  end

  def active_field_count
    fields.count do |field|
      field.fetch("active", true) == true
    end
  end

  def publish!
    transaction do
      definition_template.versions
                         .where(status: "published")
                         .where.not(id: id)
                         .update_all(
                           status: "archived",
                           deprecated_at: Time.current,
                           updated_at: Time.current
                         )

      update!(
        status: "published",
        published_at: Time.current
      )
    end
  end

  def to_catalog_hash
    {
      id: definition_template.external_id,
      name: definition_template.name,
      slug: definition_template.slug,
      category: definition_template.category,
      description: definition_template.description,
      icon: definition_template.icon,
      color: definition_template.color,
      featured: definition_template.featured,
      new: definition_template.is_new,
      active: definition_template.active,
      popularity: definition_template.popularity_score,
      usageCount: definition_template.usage_count,
      tags: Array(definition_template.tags),
      version: version,
      fields: fields,
      metadata: metadata
    }
  end
end