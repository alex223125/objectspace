# app/models/ecosystems/load_sources/entity_templates/entity_template_version.rb

class Ecosystems::LoadSources::EntityTemplates::EntityTemplateVersion < ApplicationRecord

  self.table_name =
    "ecosystems_load_sources_entity_template_versions"


  # ============================================================
  # SEARCHKICK
  # ============================================================
  #
  # Searchable fields:
  #
  # - version
  # - status
  # - entity_template_id
  # - entity_template_name
  # - display_name
  # - definition
  #
  # The definition is flattened into searchable text so that
  # searches can find field names, labels, descriptions, etc.
  #
  # ============================================================

  searchkick(
    word_start: [
      :display_name,
      :entity_template_name,
      :status,
      :search_text
    ],
    searchable: [
      :display_name,
      :entity_template_name,
      :status,
      :search_text
    ]
  )


  # ============================================================
  # ASSOCIATIONS
  # ============================================================

  belongs_to :entity_template,
             class_name:
               "Ecosystems::LoadSources::EntityTemplates::EntityTemplate",
             inverse_of:
               :entity_template_versions


  has_many :entity_template_fields,
           class_name:
             "Ecosystems::LoadSources::EntityTemplates::EntityTemplateField",
           foreign_key: :entity_template_version_id,
           inverse_of: :entity_template_version,
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
  # CALLBACKS
  # ============================================================

  before_validation :assign_version_number,
                    on: :create,
                    if: -> { version.blank? }

  before_validation :normalize_definition


  # ============================================================
  # SCOPES
  # ============================================================

  scope :latest_first,
        -> {
          order(
            version: :desc
          )
        }

  scope :oldest_first,
        -> {
          order(
            version: :asc
          )
        }

  scope :published_versions,
        -> {
          where(
            status: "published"
          )
        }

  scope :draft_versions,
        -> {
          where(
            status: "draft"
          )
        }

  scope :archived_versions,
        -> {
          where(
            status: "archived"
          )
        }


  # ============================================================
  # SEARCHKICK DATA
  # ============================================================
  #
  # Searchkick calls this method when indexing the record.
  #
  # Keep this method deterministic and inexpensive.
  #
  # ============================================================

  def search_data

    {
      id: id,

      version: version,

      status: status,

      entity_template_id:
        entity_template_id,

      entity_template_name:
        entity_template_name_for_search,

      display_name:
        display_name,

      search_text:
        search_text,

      created_at:
        created_at,

      updated_at:
        updated_at,

      published_at:
        published_at
    }

  end


  # ============================================================
  # SEARCH DISPLAY HELPERS
  # ============================================================

  def entity_template_name_for_search

    entity_template&.name.to_s

  end


  def search_text

    parts = []

    parts << display_name
    parts << entity_template_name_for_search
    parts << status
    parts << "version #{version}"

    definition_search_text =
      definition_to_search_text(
        definition
      )

    parts << definition_search_text

    parts
      .compact
      .map(&:to_s)
      .reject(&:blank?)
      .join(" ")

  end


  # ============================================================
  # VERSION HELPERS
  # ============================================================

  def latest?

    version ==
      entity_template
        .entity_template_versions
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
        .where(
          status: "published"
        )
        .where.not(
        id: id
      )
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

    entity_template
      .entity_template_versions
      .create!(
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

    definition.fetch(
      "sections",
      []
    )

  end


  def fields

    sections.flat_map do |section|

      section.fetch(
        "fields",
        []
      )

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

    "#{entity_template_name_for_search} v#{version}"

  end


  def status_label

    status.to_s.humanize

  end


  # ============================================================
  # VALIDATION
  # ============================================================

  def definition_must_be_valid

    unless definition.is_a?(Hash)

      errors.add(
        :definition,
        "must be an object"
      )

      return

    end


    # ----------------------------------------------------------
    # FIELDS
    # ----------------------------------------------------------

    if definition.key?("fields") &&
      !definition["fields"].is_a?(Array)

      errors.add(
        :definition,
        "fields must be an array"
      )

    end


    # ----------------------------------------------------------
    # SECTIONS
    # ----------------------------------------------------------

    if definition.key?("sections") &&
      !definition["sections"].is_a?(Array)

      errors.add(
        :definition,
        "sections must be an array"
      )

    end

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

    self.definition =
      if definition.nil?

        {}

      elsif definition.respond_to?(:deep_stringify_keys)

        definition.deep_stringify_keys

      else

        definition

      end

  end


  # ============================================================
  # DEFINITION → SEARCH TEXT
  # ============================================================
  #
  # Converts nested JSONB into a searchable string.
  #
  # Example:
  #
  # {
  #   "sections" => [
  #     {
  #       "name" => "Identity",
  #       "fields" => [
  #         {
  #           "name" => "Scientific Name",
  #           "label" => "Scientific Name"
  #         }
  #       ]
  #     }
  #   ]
  # }
  #
  # becomes searchable text containing:
  #
  # Identity
  # Scientific Name
  # label
  #
  # This allows Searchkick to find records by content
  # inside the JSON definition.
  #
  # ============================================================

  def definition_to_search_text(value)

    case value

    when Hash

      value
        .flat_map do |key, child|

        [
          key.to_s,
          definition_to_search_text(child)
        ]

      end
        .join(" ")

    when Array

      value
        .map do |child|

        definition_to_search_text(child)

      end
        .join(" ")

    when String

      value

    when Numeric, TrueClass, FalseClass

      value.to_s

    when NilClass

      ""

    else

      value.to_s

    end

  end

end
