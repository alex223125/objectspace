# frozen_string_literal: true

class Ecosystems::LoadSources::EntityTemplates::EntityTemplateVersions::DefinitionLibraryDefinition < ApplicationRecord

  self.table_name = "ecosystems_load_sources_entity_template_versions_definition_library_definitions"

  validates :key, presence: true, uniqueness: true
  validates :name, presence: true
  validates :category, presence: true
  validates :version, presence: true

  scope :active, -> {
    where(active: true)
  }

  scope :featured, -> {
    where(featured: true)
  }

  scope :newest, -> {
    where(new_record: true)
  }

  scope :popular, -> {
    order(popularity: :desc)
  }

  scope :alphabetical, -> {
    order(name: :asc)
  }

  scope :active_definitions, lambda {
    if column_names.include?("active")
      where(active: true)
    else
      all
    end
  }

  scope :featured_definitions, lambda {
    if column_names.include?("featured")
      where(featured: true)
    else
      none
    end
  }

  scope :popular, lambda {
    if column_names.include?("popularity")
      order(popularity: :desc)
    else
      all
    end
  }

  def field_count
    Array(fields).length
  end

  def required_field_count
    Array(fields).count do |field|
      field["required"] || field[:required]
    end
  end

  def active_field_count
    Array(fields).count do |field|
      field["active"] != false && field[:active] != false
    end
  end

  def catalog_json
    {
      id: key,
      key: key,
      name: name,
      category: category,
      description: description,
      tags: tags,
      icon: icon,
      popularity: popularity,
      featured: featured,
      new: new_record,
      version: version,
      fields: fields
    }
  end
end