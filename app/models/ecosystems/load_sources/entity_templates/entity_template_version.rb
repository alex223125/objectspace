class Ecosystems::LoadSources::EntityTemplates::EntityTemplateVersion < ApplicationRecord
  self.table_name = "ecosystems_load_sources_entity_template_versions"

  belongs_to :entity_template,
             class_name: "Ecosystems::LoadSources::EntityTemplates::EntityTemplate"

  validates :version, presence: true
  validates :status, presence: true

  validates :version,
            uniqueness: {
              scope: :entity_template_id
            }

  scope :draft, -> { where(status: "draft") }
  scope :published, -> { where(status: "published") }

  def published?
    status == "published"
  end

  def draft?
    status == "draft"
  end
end
