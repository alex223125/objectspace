# frozen_string_literal: true

class Ecosystems::LoadSources::EntityTemplates::EntityTemplateVersions::DefinitionTemplate < ApplicationRecord
  self.table_name =
    "ecosystems_load_sources_entity_template_versions_definition_templates"

  has_many :versions,
           class_name: "Ecosystems::LoadSources::EntityTemplates::EntityTemplateVersions::DefinitionTemplateVersion",
           foreign_key: :definition_template_id,
           inverse_of: :definition_template,
           dependent: :destroy

  has_many :usages,
           class_name: "DefinitionTemplateUsage",
           foreign_key: :definition_template_id,
           dependent: :destroy

  has_one :published_version,
          -> { where(status: "published") },
          class_name: "Ecosystems::LoadSources::EntityTemplates::EntityTemplateVersions::DefinitionTemplateVersion",
          foreign_key: :definition_template_id

  validates :external_id,
            presence: true,
            uniqueness: true

  validates :name,
            presence: true

  validates :slug,
            presence: true,
            uniqueness: true

  validates :category,
            presence: true

  validates :status,
            inclusion: {
              in: %w[draft published archived]
            }

  scope :active, -> {
    where(active: true)
  }

  scope :published, -> {
    where(status: "published")
  }

  scope :featured, -> {
    where(featured: true)
  }

  scope :newest, -> {
    where(is_new: true)
  }

  scope :popular, -> {
    order(popularity_score: :desc, usage_count: :desc)
  }

  scope :alphabetical, -> {
    order(Arel.sql("LOWER(name) ASC"))
  }

  scope :reverse_alphabetical, -> {
    order(Arel.sql("LOWER(name) DESC"))
  }

  scope :by_category, ->(category) {
    if category.present? && category.to_s.upcase != "ALL"
      where(category: category)
    else
      all
    end
  }

  scope :with_tag, ->(tag) {
    return all if tag.blank?

    where(
      <<~SQL.squish,
        EXISTS (
          SELECT 1
          FROM jsonb_array_elements_text(
            ecosystems_load_sources_entity_template_versions_definition_templates.tags
          ) AS tag
          WHERE LOWER(tag) = LOWER(?)
        )
      SQL
      tag
    )
  }

  scope :search, ->(query) {
    return all if query.blank?

    normalized = "%#{query.to_s.downcase.strip}%"

    where(
      <<~SQL.squish,
        LOWER(name) LIKE :query
        OR LOWER(description) LIKE :query
        OR LOWER(category) LIKE :query
        OR EXISTS (
          SELECT 1
          FROM jsonb_array_elements_text(
            ecosystems_load_sources_entity_template_versions_definition_templates.tags
          ) AS tag
          WHERE LOWER(tag) LIKE :query
        )
      SQL
      query: normalized
    )
  }

  def current_version
    published_version ||
      versions.order(version: :desc).first
  end

  def fields
    Array(current_version&.definition&.fetch("fields", []))
  end

  def field_count
    fields.length
  end

  def required_field_count
    fields.count { |field| field["required"] == true }
  end

  def active_field_count
    fields.count { |field| field.fetch("active", true) == true }
  end

  def current_version_number
    current_version&.version
  end

  def record_usage!(event_type:, user: nil, source: nil, session_id: nil, metadata: {})
    version = current_version

    usages.create!(
      definition_template_version: version,
      user: user,
      event_type: event_type,
      source: source,
      session_id: session_id,
      metadata: metadata
    )

    case event_type.to_s
    when "imported"
      increment!(:usage_count)
      increment!(:popularity_score, 5)
    when "viewed"
      increment!(:popularity_score, 1)
    end
  end

  def to_catalog_hash
    version = current_version

    {
      id: external_id,
      name: name,
      slug: slug,
      category: category,
      description: description,
      icon: icon,
      color: color,
      featured: featured,
      new: is_new,
      active: active,
      popularity: popularity_score,
      usageCount: usage_count,
      tags: Array(tags),
      version: version&.version,
      fields: Array(version&.definition&.fetch("fields", [])),
      metadata: metadata || {}
    }
  end
end