# app/models/ecosystems/load_sources/entity_templates/entity_template_version.rb

class Ecosystems::LoadSources::EntityTemplates::EntityTemplateVersion < ApplicationRecord

  self.table_name =
    "ecosystems_load_sources_entity_template_versions"


  # ============================================================
  # SEARCHKICK
  # ============================================================

  searchkick(
    word_start: [
      :display_name,
      :entity_template_name,
      :status,
      :search_text
    ],
    searchable: [
      :version,
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

  has_many :entities,
           class_name: "Ecosystems::LoadSources::Entity::Entity",
           foreign_key: :entity_template_version_id,
           inverse_of: :entity_template_version


  # ============================================================
  # ENUM
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
            presence: true,
            inclusion: {
              in: statuses.keys
            }

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
          order(version: :desc)
        }

  scope :oldest_first,
        -> {
          order(version: :asc)
        }

  scope :published_versions,
        -> {
          where(status: "published")
        }

  scope :draft_versions,
        -> {
          where(status: "draft")
        }

  scope :archived_versions,
        -> {
          where(status: "archived")
        }


  # ============================================================
  # VERSION COLLECTION HELPERS
  # ============================================================

  def latest_version
    entity_template
      &.entity_template_versions
      &.latest_first
      &.first
  end

  def published_version
    entity_template
      &.entity_template_versions
      &.published_versions
      &.latest_first
      &.first
  end

  def versions_count
    entity_template
      &.entity_template_versions
      &.count
      .to_i
  end


  # ============================================================
  # SEARCH DATA
  # ============================================================

  def search_data

    {
      id: id,
      version: version,
      status: status,
      entity_template_id: entity_template_id,
      entity_template_name: entity_template_name_for_search,
      display_name: display_name,
      search_text: search_text,
      created_at: created_at,
      updated_at: updated_at,
      published_at: published_at
    }

  end


  # ============================================================
  # SEARCH HELPERS
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

    parts << definition_to_search_text(definition)

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

    return false unless entity_template.present?

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

    raise ActiveRecord::RecordInvalid,
          "Only a draft version can be published." unless draft?

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

  def create_next_version!

    raise ActiveRecord::RecordInvalid,
          "Entity template is required." unless entity_template.present?

    self.class.transaction(requires_new: true) do

      next_version =
        entity_template
          .entity_template_versions
          .lock
          .maximum(:version)
          .to_i + 1

      entity_template
        .entity_template_versions
        .create!(
          version: next_version,
          status: "draft",
          definition: definition.deep_dup
        )

    end

  rescue ActiveRecord::RecordNotUnique

    retry

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
  # DISPLAY
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


    if definition.key?("fields") &&
      !definition["fields"].is_a?(Array)

      errors.add(
        :definition,
        "fields must be an array"
      )

    end


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
    return if version.present?

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
  # DEFINITION -> SEARCH TEXT
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