class Ecosystems::LoadSources::EntityTemplates::EntityTemplate < ApplicationRecord
  self.table_name = "ecosystems_load_sources_entity_templates"

  extend Pagy::Searchkick

  searchkick callbacks: :async,
             word_start: [:name, :slug, :description],
             word_middle: [:name, :slug, :description]

  belongs_to :entity_type,
             class_name: "Ecosystems::LoadSources::EntityTypes::EntityType"

  has_many :entity_template_versions,
           class_name:
             "Ecosystems::LoadSources::EntityTemplates::EntityTemplateVersion",
           foreign_key: :entity_template_id,
           inverse_of: :entity_template,
           dependent: :destroy

  def versions
    self.entity_template_versions
  end

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :entity_type, presence: true

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }

  before_validation :generate_slug, if: -> { slug.blank? }

  def latest_version
    versions.order(version: :desc).first
  end

  def published_version
    versions.published.order(version: :desc).first
  end

  def versions_count
    versions.count
  end

  private

  def generate_slug
    self.slug = name.to_s.parameterize
  end

  def search_data
    {
      name: name,
      slug: slug,
      description: description,
      entity_type_id: entity_type_id,
      entity_type_name: entity_type&.name,
      active: active
    }
  end
end
