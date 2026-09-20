# frozen_string_literal: true

module Ecosystems
  module LoadSources
    module Entity

      class Entity < ApplicationRecord

        self.table_name = "ecosystems_load_sources_entities"

        # ==========================================================
        # CALLBACKS
        # ==========================================================

        after_initialize :set_default_scope, if: :new_record?

        before_validation :assign_entity_template_version, on: :create

        # ==========================================================
        # ASSOCIATIONS
        # ==========================================================

        belongs_to :entity_type,
                   class_name: "Ecosystems::LoadSources::EntityTypes::EntityType"

        belongs_to :entity_template,
                   class_name: "Ecosystems::LoadSources::EntityTemplates::EntityTemplate"

        belongs_to :entity_template_version,
                   class_name: "Ecosystems::LoadSources::EntityTemplates::EntityTemplateVersion",
                   optional: true

        # ==========================================================
        # ENUMS
        # ==========================================================

        enum scope: {
          conceptual: "conceptual",
          real_world: "real_world",
          hybrid: "hybrid"
        }, _prefix: true

        enum status: {
          draft: "draft",
          published: "published",
          archived: "archived",
          deprecated: "deprecated"
        }, _prefix: true

        # ==========================================================
        # VALIDATIONS
        # ==========================================================

        validates :name, presence: true
        validates :slug, presence: true, uniqueness: true

        validates :entity_type, presence: true
        validates :entity_template, presence: true
        validates :entity_template_version, presence: true
        validates :scope, presence: true

        validate :entity_template_version_matches_template

        # ==========================================================
        # VERSIONING / HISTORY
        # ==========================================================

        has_many :versions,
                 class_name:
                   "Ecosystems::LoadSources::Entity::EntityVersion",
                 foreign_key: :entity_id,
                 dependent: :restrict_with_exception

        belongs_to :current_version,
                   class_name:
                     "Ecosystems::LoadSources::Entity::EntityVersion",
                   foreign_key: :current_version_id,
                   optional: true

        has_many :events,
                 class_name:
                   "Ecosystems::LoadSources::Entity::EntityEvent",
                 foreign_key: :entity_id,
                 dependent: :restrict_with_exception

        # ==========================================================
        # LIFECYCLE
        # ==========================================================

        def published?
          status.to_s == "published"
        end

        def archived?
          status.to_s == "archived"
        end

        def deprecated?
          status.to_s == "deprecated"
        end

        def draft?
          status.to_s == "draft"
        end

        # ==========================================================
        # VERSION HELPERS
        # ==========================================================

        def next_version_number
          versions.maximum(:version_number).to_i + 1
        end

        def latest_version
          versions.order(version_number: :desc).first
        end

        def version_count
          versions.count
        end

        # ==========================================================
        # EVENT HELPERS
        # ==========================================================

        def record_event!(
          event_type:,
          entity_version: nil,
          from_status: nil,
          to_status: nil,
          actor: nil,
          metadata: {}
        )
          events.create!(
            event_type: event_type,
            entity_version: entity_version,
            from_status: from_status,
            to_status: to_status,
            actor: actor,
            occurred_at: Time.current,
            metadata: metadata || {}
          )
        end

        # ==========================================================
        # SEARCHKICK
        # ==========================================================

        searchkick(
          word_start: [
            :name,
            :slug
          ],

          searchable: [
            :name,
            :slug,
            :summary
          ],

          settings: {
            analysis: {
              analyzer: {
                searchkick_search: {
                  type: "custom",
                  tokenizer: "standard",
                  filter: [
                    "lowercase"
                  ]
                },

                searchkick_search2: {
                  type: "custom",
                  tokenizer: "standard",
                  filter: [
                    "lowercase",
                    "asciifolding"
                  ]
                },

                searchkick_word_start_index: {
                  type: "custom",
                  tokenizer: "keyword",
                  filter: [
                    "lowercase",
                    "asciifolding"
                  ]
                },

                searchkick_word_start_search: {
                  type: "custom",
                  tokenizer: "standard",
                  filter: [
                    "lowercase",
                    "asciifolding"
                  ]
                }
              },

              normalizer: {
                searchkick_lowercase: {
                  type: "custom",
                  filter: [
                    "lowercase",
                    "asciifolding"
                  ]
                }
              }
            }
          },

          mappings: {
            properties: {
              id: { type: "integer" },

              name: {
                type: "text",
                analyzer: "searchkick_search",
                search_analyzer: "searchkick_search",
                fields: {
                  keyword: {
                    type: "keyword"
                  }
                }
              },

              slug: {
                type: "text",
                analyzer: "searchkick_word_start_index",
                search_analyzer: "searchkick_word_start_search",
                fields: {
                  keyword: {
                    type: "keyword"
                  }
                }
              },

              summary: {
                type: "text",
                analyzer: "searchkick_search",
                search_analyzer: "searchkick_search"
              },

              status: {
                type: "keyword"
              },

              scope: {
                type: "keyword"
              },

              entity_type_id: {
                type: "integer"
              },

              entity_type_name: {
                type: "keyword"
              },

              entity_template_id: {
                type: "integer"
              },

              entity_template_name: {
                type: "keyword"
              },

              entity_template_version_id: {
                type: "long"
              },

              health_score: {
                type: "integer"
              },

              health_level: {
                type: "keyword"
              },

              quality_complete: {
                type: "boolean"
              },

              quality_flags: {
                type: "keyword"
              },

              created_at: {
                type: "date"
              },

              updated_at: {
                type: "date"
              }
            }
          }
        )

        # ==========================================================
        # ENTITY HEALTH
        # ==========================================================

        def health_score
          checks = health_checks

          return 0 if checks.empty?

          completed = checks.count do |_key, check|
            check[:complete]
          end

          (
            completed.to_f /
              checks.length *
              100
          ).round
        end

        def health_level
          score = health_score

          case score
          when 90..100
            :excellent
          when 70...90
            :good
          when 40...70
            :needs_attention
          else
            :critical
          end
        end

        def health_checks
          {
            identity: {
              label: "Identity",
              complete: name.present? && slug.present?,
              weight: 20
            },

            entity_type: {
              label: "Entity Type",
              complete: entity_type.present?,
              weight: 15
            },

            template: {
              label: "Template",
              complete: entity_template.present?,
              weight: 15
            },

            summary: {
              label: "Summary",
              complete: summary.present?,
              weight: 15
            },

            scope: {
              label: "Scope",
              complete: scope.present?,
              weight: 10
            },

            status: {
              label: "Lifecycle Status",
              complete: status.present?,
              weight: 10
            },

            metadata: {
              label: "Metadata",
              complete: metadata.present?,
              weight: 5
            },

            temporal: {
              label: "Temporal Data",
              complete:
                valid_from.present? ||
                  valid_until.present? ||
                  observed_at.present?,
              weight: 10
            }
          }
        end

        def health_summary
          {
            score: health_score,
            level: health_level,
            checks: health_checks
          }
        end

        # ==========================================================
        # QUALITY FLAGS
        # ==========================================================

        def quality_flags
          flags = []

          flags << :missing_name if name.blank?
          flags << :missing_slug if slug.blank?
          flags << :missing_entity_type if entity_type.blank?
          flags << :missing_template if entity_template.blank?
          flags << :missing_summary if summary.blank?
          flags << :missing_scope if scope.blank?

          flags
        end

        def quality_issues
          quality_flags.map do |flag|
            case flag
            when :missing_name
              "Missing entity name."
            when :missing_slug
              "Missing slug."
            when :missing_entity_type
              "No entity type assigned."
            when :missing_template
              "No entity template assigned."
            when :missing_summary
              "Missing summary."
            when :missing_scope
              "Scope has not been assigned."
            else
              flag.to_s.humanize
            end
          end
        end

        def complete?
          quality_flags.empty?
        end

        # ==========================================================
        # SEARCHKICK DATA
        # ==========================================================

        def search_data
          {
            id: id,
            name: name,
            slug: slug,
            summary: summary,
            status: status,
            scope: scope,

            entity_type_id: entity_type_id,
            entity_type_name: entity_type&.name,

            entity_template_id: entity_template_id,
            entity_template_name: entity_template&.name,

            entity_template_version_id: entity_template_version_id,

            health_score: health_score,
            health_level: health_level.to_s,

            quality_complete: complete?,
            quality_flags: quality_flags.map(&:to_s),

            created_at: created_at&.iso8601,
            updated_at: updated_at&.iso8601
          }
        end

        private

        # ==========================================================
        # DEFAULT SCOPE
        # ==========================================================

        def set_default_scope
          self.scope ||= "conceptual"
        end

        # ==========================================================
        # TEMPLATE VERSION
        # ==========================================================

        def assign_entity_template_version
          return if entity_template_version.present?
          return if entity_template.blank?

          self.entity_template_version =
            entity_template.published_version ||
              entity_template.latest_version
        end

        # ==========================================================
        # TEMPLATE / VERSION CONSISTENCY
        # ==========================================================

        def entity_template_version_matches_template
          return if entity_template_version.blank?
          return if entity_template.blank?

          version_template_id =
            if entity_template_version.respond_to?(:entity_template_id)
              entity_template_version.entity_template_id
            end

          return if version_template_id.blank?
          return if version_template_id == entity_template_id

          errors.add(
            :entity_template_version,
            "must belong to the selected entity template."
          )
        end

      end

    end
  end
end