# app/models/entity_template_version.rb

class Ecosystems::LoadSources::EntityTemplates::EntityTemplateVersion < ApplicationRecord

  self.table_name =
    "ecosystems_load_sources_entity_template_versions"


  # ============================================================
  # ASSOCIATIONS
  # ============================================================

  belongs_to :entity_template,
             class_name:
               "Ecosystems::LoadSources::EntityTemplates::EntityTemplate",
             foreign_key: :entity_template_id

  has_many :entity_template_fields,
           class_name:
             "Ecosystems::LoadSources::EntityTemplates::EntityTemplateField",
           foreign_key: :entity_template_version_id,
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
    version ==
      self.class
          .where(entity_template_id: entity_template_id)
          .maximum(:version)
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
    self.class
        .where(entity_template_id: entity_template_id)
        .maximum(:version)
        .to_i + 1
  end


  # ============================================================
  # PUBLISH
  # ============================================================

  def publish!
    transaction do

      self.class
          .where(
            entity_template_id: entity_template_id,
            status: "published"
          )
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

    self.class.create!(
      entity_template_id: entity_template_id,
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
    definition.fetch("fields", [])
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
  # DEFINITION VALIDATION
  # ============================================================

  def definition_must_be_valid

    unless definition.is_a?(Hash)
      errors.add(
        :definition,
        "must be an object"
      )

      return
    end

    unless definition["fields"].is_a?(Array)
      errors.add(
        :definition,
        "must contain fields"
      )

      return
    end

    definition["fields"].each_with_index do |field, index|

      unless field.is_a?(Hash)
        errors.add(
          :definition,
          "field #{index + 1} must be an object"
        )

        next
      end

      if field["name"].blank?
        errors.add(
          :definition,
          "field #{index + 1} must have a name"
        )
      end

      if field["label"].blank?
        errors.add(
          :definition,
          "field #{index + 1} must have a label"
        )
      end

      if field["type"].blank?
        errors.add(
          :definition,
          "field #{index + 1} must have a type"
        )
      end

    end

  end


  # ============================================================
  # AUTOMATIC VERSION NUMBER
  # ============================================================

  def assign_version_number

    return if entity_template_id.blank?

    self.version =
      self.class
          .where(
            entity_template_id: entity_template_id
          )
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