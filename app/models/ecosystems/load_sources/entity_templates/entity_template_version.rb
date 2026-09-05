# app/models/entity_template_version.rb

class Ecosystems::LoadSources::EntityTemplates::EntityTemplateVersion < ApplicationRecord

  self.table_name = "ecosystems_load_sources_entity_template_versions"


  # ============================================================
  # ASSOCIATIONS
  # ============================================================

  belongs_to :entity_template,
             class_name: "Ecosystems::LoadSources::EntityTemplates::EntityTemplate"


  has_many :entity_template_fields,
           class_name: "Ecosystems::LoadSources::EntityTemplateField",
           dependent: :destroy


  # ============================================================
  # ENUMS
  # ============================================================

  enum :status, {
    draft: "draft",
    published: "published",
    archived: "archived"
  }


  # ============================================================
  # VALIDATIONS
  # ============================================================

  validates :version,
            presence: true,
            numericality: {
              only_integer: true,
              greater_than: 0
            }

  validates :version,
            uniqueness: {
              scope: :entity_template_id
            }

  validates :status,
            presence: true

  validates :definition,
            presence: true


  validate :definition_must_be_valid

  def definition_must_be_valid
    unless definition.is_a?(Hash)
      errors.add(:definition, "must be an object")
      return
    end

    unless definition["fields"].is_a?(Array)
      errors.add(:definition, "must contain fields")
    end
  end


  # ============================================================
  # SCOPES
  # ============================================================

  scope :latest_first,
        -> { order(version: :desc) }

  scope :oldest_first,
        -> { order(version: :asc) }

  scope :published_versions,
        -> { where(status: "published") }

  scope :draft_versions,
        -> { where(status: "draft") }

  scope :archived_versions,
        -> { where(status: "archived") }


  # ============================================================
  # CALLBACKS
  # ============================================================

  before_validation :assign_version_number,
                    on: :create,
                    if: -> { version.blank? }

  before_validation :normalize_definition


  # ============================================================
  # VERSION HELPERS
  # ============================================================

  def latest?
    version == entity_template.entity_template_versions.maximum(:version)
  end


  def published?
    status == "published"
  end


  def draft?
    status == "draft"
  end


  def archived?
    status == "archived"
  end


  # ============================================================
  # VERSION NUMBERING
  # ============================================================

  def next_version_number
    entity_template
      .entity_template_versions
      .maximum(:version)
      .to_i + 1
  end


  # ============================================================
  # PUBLISH
  # ============================================================

  def publish!
    transaction do
      entity_template
        .entity_template_versions
        .where(status: "published")
        .where.not(id: id)
        .update_all(
          status: "archived",
          updated_at: Time.current
        )

      update!(
        status: "published",
        published_at: Time.current
      )
    end
  end


  # ============================================================
  # ARCHIVE
  # ============================================================

  def archive!
    raise ActiveRecord::RecordInvalid,
          "Only a published version can be archived." unless published?

    transaction do
      update!(
        status: "archived"
      )
    end
  end


  # ============================================================
  # CLONE
  # ============================================================

  def create_next_version!(created_by_id: nil)
    entity_template.entity_template_versions.create!(
      version: next_version_number,
      status: "draft",
      definition: definition.deep_dup,
      created_by_id: created_by_id
    )
  end


  # ============================================================
  # DEFINITION HELPERS
  # ============================================================

  def sections
    definition.fetch("sections", [])
  end


  def fields
    sections.flat_map do |section|
      section.fetch("fields", [])
    end
  end


  def field_count
    fields.size
  end


  def section_count
    sections.size
  end


  # ============================================================
  # DISPLAY HELPERS
  # ============================================================

  def display_name
    "#{entity_template.name} v#{version}"
  end


  def status_label
    status.to_s.humanize
  end


  private


  # ============================================================
  # AUTOMATIC VERSION NUMBER
  # ============================================================

  def assign_version_number
    return if entity_template.blank?

    self.version =
      entity_template
        .entity_template_versions
        .maximum(:version)
        .to_i + 1
  end


  # ============================================================
  # NORMALIZE JSONB
  # ============================================================

  def normalize_definition
    self.definition = {} if definition.nil?
  end
end
