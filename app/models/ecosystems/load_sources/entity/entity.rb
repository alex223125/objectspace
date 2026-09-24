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
                   class_name:
                     "Ecosystems::LoadSources::EntityTypes::EntityType"

        belongs_to :entity_template,
                   class_name:
                     "Ecosystems::LoadSources::EntityTemplates::EntityTemplate"

        belongs_to :entity_template_version,
                   class_name:
                     "Ecosystems::LoadSources::EntityTemplates::EntityTemplateVersion",
                   optional: true

        has_many :versions,
                 class_name:
                   "Ecosystems::LoadSources::Entity::EntityVersion",
                 foreign_key: :entity_id,
                 dependent: :restrict_with_exception

        has_many :events,
                 class_name:
                   "Ecosystems::LoadSources::Entity::EntityEvent",
                 foreign_key: :entity_id,
                 dependent: :restrict_with_exception

        has_many :entity_versions,
                 -> { order(version_number: :asc) },
                 dependent: :restrict_with_exception

        has_one :current_version,
                class_name: "Ecosystems::LoadSources::Entity::EntityVersion",
                foreign_key: :id,
                primary_key: :current_version_id

        has_many :entity_events,
                 -> { order(occurred_at: :asc) },
                 dependent: :restrict_with_exception


        # Add these associations to your existing Entity class.

        belongs_to :reviewer,
                   class_name: "User",
                   optional: true

        belongs_to :reviewer_assigned_by,
                   class_name: "User",
                   optional: true

        belongs_to :change_requested_by,
                   class_name: "User",
                   optional: true

        has_many :editorial_comments,
                 class_name:
                   "Ecosystems::LoadSources::Entity::EntityEditorialComment",
                 foreign_key: :entity_id,
                 dependent: :restrict_with_exception


        # ==========================================================
        # EDITORIAL WORKFLOW
        # ==========================================================

        has_many :editorial_events,
                 -> {
                   where(
                     event_type: [
                       "submitted_for_review",
                       "reviewer_assigned",
                       "comment_added",
                       "approved",
                       "rejected",
                       "change_requested"
                     ]
                   )
                 },
                 class_name:
                   "Ecosystems::LoadSources::Entity::EntityEvent",
                 foreign_key: :entity_id


        # ==========================================================
        # EDITORIAL WORKFLOW
        # ==========================================================

        belongs_to :reviewer,
                   class_name: "User",
                   foreign_key: :reviewer_id,
                   optional: true

        belongs_to :submitted_by,
                   class_name: "User",
                   foreign_key: :submitted_by_id,
                   optional: true

        belongs_to :approved_by,
                   class_name: "User",
                   foreign_key: :approved_by_id,
                   optional: true

        belongs_to :rejected_by,
                   class_name: "User",
                   foreign_key: :rejected_by_id,
                   optional: true

        belongs_to :reviewer_assigned_by,
                   class_name: "User",
                   foreign_key: :reviewer_assigned_by_id,
                   optional: true

        belongs_to :published_by,
                   class_name: "User",
                   foreign_key: :published_by_id,
                   optional: true

        def editorial_state?
          %w[
    draft
    review
    approved
    rejected
    published
  ].include?(workflow_state.to_s)
        end


        # ==========================================================
        # EDITORIAL ASSOCIATIONS
        # ==========================================================

        belongs_to :assigned_reviewer,
                   class_name: "User",
                   optional: true

        has_many :editorial_comments,
                 class_name:
                   "Ecosystems::LoadSources::Entity::EditorialComment",
                 foreign_key: :entity_id,
                 dependent: :restrict_with_exception

        has_many :change_requests,
                 class_name:
                   "Ecosystems::LoadSources::Entity::ChangeRequest",
                 foreign_key: :entity_id,
                 dependent: :restrict_with_exception

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

        enum workflow_state: {
          draft: "draft",
          review: "review",
          approved: "approved",
          published: "published",
          rejected: "rejected"
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
        # WORKFLOW
        # ==========================================================

        def can_submit_for_review?
          workflow_state_draft? ||
            workflow_state_rejected?
        end

        def can_approve?
          workflow_state_review?
        end

        def can_reject?
          workflow_state_review?
        end

        def can_publish?
          workflow_state_approved?
        end

        def can_schedule_publish?
          workflow_state_approved? &&
            publish_at.blank?
        end

        def can_unschedule_publish?
          publish_at.present? &&
            publish_at > Time.current
        end

        def reviewer_assigned?
          reviewer_id.present?
        end

        # ----------------------------------------------------------
        # Scheduling
        # ----------------------------------------------------------

        def scheduled_for_publish?
          publish_at.present? &&
            publish_at > Time.current &&
            !status_published? &&
            !status_archived? &&
            !status_deprecated?
        end

        def publish_scheduled?
          scheduled_for_publish?
        end

        def schedule_overdue?
          publish_at.present? &&
            publish_at <= Time.current &&
            !status_published?
        end

        def workflow_terminal?
          workflow_state_published?
        end

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
        # EDITORIAL WORKFLOW
        # ==========================================================

        def awaiting_review?
          workflow_state_review?
        end

        def assigned_reviewer?
          assigned_reviewer_id.present?
        end

        def can_request_changes?
          workflow_state_review?
        end

        def open_change_requests
          change_requests.open
        end

        def has_open_change_requests?
          change_requests.open.exists?
        end

        def editorial_queue?
          workflow_state_review?
        end

        # ----------------------------------------------------------
        # EDITORIAL STATE HELPERS
        # ----------------------------------------------------------

        def can_assign_reviewer?
          workflow_state_review?
        end

        def changes_requested?
          workflow_state_rejected?
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
            workflow_state: workflow_state,
            scope: scope,

            entity_type_id: entity_type_id,
            entity_type_name: entity_type&.name,

            entity_template_id: entity_template_id,
            entity_template_name: entity_template&.name,

            entity_template_version_id:
            entity_template_version_id,

            health_score: health_score,
            health_level: health_level.to_s,

            quality_complete: complete?,
            quality_flags: quality_flags.map(&:to_s),

            publish_at: publish_at&.iso8601,
            published_at: published_at&.iso8601,

            created_at: created_at&.iso8601,
            updated_at: updated_at&.iso8601,

            assigned_reviewer_id: assigned_reviewer_id,
            review_requested_at: review_requested_at&.iso8601,
            reviewed_at: reviewed_at&.iso8601
          }
        end

        private

        # ==========================================================
        # DEFAULTS
        # ==========================================================

        def set_default_scope
          self.scope ||= "conceptual"
          self.workflow_state ||= "draft"
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