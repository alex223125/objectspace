# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities

        class EntitiesController < ApplicationController

          before_action :set_entity,
                        only: %i[
                show
                edit
                update
                destroy
                clone
                archive
                restore
                publish
                deprecate
                compare
                history
                version
                schedule_publish
                cancel_schedule
              ]

          # ==========================================================
          # INDEX
          # ==========================================================

          def index
            @entity_types =
              ::Ecosystems::LoadSources::EntityTypes::EntityType
                .where(active: true)
                .order(:name)

            @entity_templates =
              ::Ecosystems::LoadSources::EntityTemplates::EntityTemplate
                .order(:name)

            @search_results = search_entities

            @entities = @search_results.to_a

            @entity_total =
              @search_results.total_count

            @current_page =
              normalized_page

            @per_page =
              normalized_per_page

            @total_pages =
              if @entity_total.zero?
                1
              else
                (@entity_total.to_f / @per_page).ceil
              end

            @facets =
              build_facets(@search_results)

            content =
              render_to_string(
                template:
                  "admin/ecosystems/load_sources/entities/entities/index",
                layout: false
              )

            render(
              template:
                "admin/ecosystems/load_sources/entity_templates/layout/entity_templates_layout",
              layout: false,
              locals: {
                content: content
              }
            )
          end

          # ==========================================================
          # SHOW
          # ==========================================================

          def show
            content =
              render_to_string(
                template:
                  "admin/ecosystems/load_sources/entities/entities/show",
                layout: false
              )

            render(
              template:
                "admin/ecosystems/load_sources/entity_templates/layout/entity_templates_layout",
              layout: false,
              locals: {
                content: content
              }
            )
          end

          # ==========================================================
          # NEW
          # ==========================================================

          def new
            @entity =
              ::Ecosystems::LoadSources::Entity::Entity.new(
                status: "draft",
                workflow_state: "draft"
              )

            @entity_types =
              ::Ecosystems::LoadSources::EntityTypes::EntityType
                .where(active: true)
                .order(:name)

            @entity_templates =
              ::Ecosystems::LoadSources::EntityTemplates::EntityTemplate
                .includes(:versions)
                .order(:name)

            content =
              render_to_string(
                template:
                  "admin/ecosystems/load_sources/entities/entities/new",
                layout: false
              )

            render(
              template:
                "admin/ecosystems/load_sources/entity_templates/layout/entity_templates_layout",
              layout: false,
              locals: {
                content: content
              }
            )
          end

          # ==========================================================
          # CREATE
          # ==========================================================

          def create
            @entity =
              ::Ecosystems::LoadSources::Entity::Entity.new(
                entity_params
              )

            @entity.status ||= :draft
            @entity.scope ||= :conceptual
            @entity.workflow_state ||= :draft

            if @entity.save
              record_event(
                :created,
                metadata: {
                  status: @entity.status,
                  workflow_state: @entity.workflow_state
                }
              )

              redirect_to(
                admin_ecosystems_load_sources_entity_path(@entity),
                notice: "Entity created successfully."
              )
            else
              @entity_types =
                ::Ecosystems::LoadSources::EntityTypes::EntityType
                  .where(active: true)
                  .order(:name)

              @entity_templates =
                ::Ecosystems::LoadSources::EntityTemplates::EntityTemplate
                  .order(:name)

              content =
                render_to_string(
                  template:
                    "admin/ecosystems/load_sources/entities/entities/new",
                  layout: false
                )

              render(
                template:
                  "admin/ecosystems/load_sources/entity_templates/layout/entity_templates_layout",
                layout: false,
                status: :unprocessable_entity,
                locals: {
                  content: content
                }
              )
            end
          end

          # ==========================================================
          # EDIT
          # ==========================================================

          def edit
            content =
              render_to_string(
                template:
                  "admin/ecosystems/load_sources/entities/entities/edit",
                layout: false
              )

            render(
              template:
                "admin/ecosystems/load_sources/entity_templates/layout/entity_templates_layout",
              layout: false,
              locals: {
                content: content
              }
            )
          end

          # ==========================================================
          # UPDATE
          # ==========================================================

          def update
            previous_workflow_state =
              @entity.workflow_state.to_s

            previous_publish_at =
              @entity.publish_at

            @entity.assign_attributes(entity_params)

            content_changed =
              @entity.changes.keys.any? do |attribute|
                editorial_content_attribute?(attribute)
              end

            ActiveRecord::Base.transaction do
              @entity.save!

              if content_changed &&
                (
                  previous_workflow_state == "approved" ||
                    previous_publish_at.present?
                )

                ::Ecosystems::LoadSources::Entities::InvalidateApproval.call!(
                  entity: @entity,
                  actor: current_user,
                  reason:
                    "Editorial content changed after approval."
                )
              else
                record_event(
                  :updated,
                  metadata: {
                    workflow_state:
                      @entity.workflow_state
                  }
                )
              end
            end

            redirect_to(
              admin_ecosystems_load_sources_entity_path(@entity),
              notice: "Entity updated successfully."
            )

          rescue ActiveRecord::RecordInvalid => e

            flash.now[:alert] =
              "Unable to update entity: #{e.message}"

            render :edit,
                   status: :unprocessable_entity
          end

          # ==========================================================
          # DESTROY
          # ==========================================================

          def destroy
            @entity.destroy!

            redirect_to(
              admin_ecosystems_load_sources_entities_path,
              notice: "Entity deleted successfully."
            )
          end


          # ==========================================================
          # version
          # ==========================================================

          def version
            @version =
              ::Ecosystems::LoadSources::Entity::EntityVersion
                .where(entity_id: @entity.id)
                .find(params[:version_id])

            content =
              render_to_string(
                template:
                  "admin/ecosystems/load_sources/entities/entities/version",
                layout: false
              )

            render(
              template:
                "admin/ecosystems/load_sources/entity_templates/layout/entity_templates_layout",
              layout: false,
              locals: {
                content: content
              }
            )
          end

          # ==========================================================
          # CLONE
          # ==========================================================

          def clone
            cloned_entity = @entity.dup

            cloned_entity.name =
              "#{@entity.name} Copy"

            cloned_entity.slug = nil
            cloned_entity.status = "draft"
            cloned_entity.workflow_state = "draft"

            cloned_entity.current_version_id = nil if
              cloned_entity.respond_to?(:current_version_id)

            cloned_entity.publish_at = nil

            if cloned_entity.save
              record_event_for(
                cloned_entity,
                :cloned,
                metadata: {
                  source_entity_id: @entity.id
                }
              )

              redirect_to(
                admin_ecosystems_load_sources_entity_path(
                  cloned_entity
                ),
                notice: "Entity cloned successfully."
              )
            else
              redirect_to(
                admin_ecosystems_load_sources_entity_path(@entity),
                alert:
                  "Unable to clone entity: " \
                    "#{cloned_entity.errors.full_messages.to_sentence}"
              )
            end
          end

          # ==========================================================
          # CANCEL SCHEDULE
          # ==========================================================

          def cancel_schedule
            policy =
              ::Ecosystems::LoadSources::EntityPolicy.new(
                current_user,
                @entity
              )

            unless policy.cancel_scheduled_publish?
              redirect_to_entity(
                "You are not allowed to cancel scheduled publication.",
                :alert
              )

              return
            end

            reason =
              params[:reason].to_s.strip.presence

            ::Ecosystems::LoadSources::Entities::CancelEntityPublish.call!(
              entity: @entity,
              actor: current_user,
              reason: reason
            )

            redirect_to_entity(
              "Scheduled publication cancelled."
            )

          rescue ArgumentError => e

            redirect_to_entity(
              e.message,
              :alert
            )
          end

          # ==========================================================
          # PUBLISH
          # ==========================================================

          def publish
            unless @entity.can_publish?
              redirect_to_entity(
                "Only approved entities can be published.",
                :alert
              )

              return
            end

            if @entity.publish_at.present? &&
              @entity.publish_at > Time.current

              redirect_to_entity(
                "Entity is scheduled for publication at " \
                  "#{@entity.publish_at}.",
                :alert
              )

              return
            end

            ::Ecosystems::LoadSources::Entity::EntityLifecycle.publish!(
              entity: @entity,
              actor: current_user,
              scheduled: false
            )

            redirect_to_entity(
              "Entity was published successfully."
            )

          rescue ::Ecosystems::LoadSources::Entity::EntityLifecycle::InvalidState => e

            redirect_to_entity(
              e.message,
              :alert
            )

          rescue ::Ecosystems::LoadSources::Entity::EntityLifecycle::ValidationError => e

            redirect_to_entity(
              e.message,
              :alert
            )

          rescue ActiveRecord::RecordInvalid => e

            redirect_to_entity(
              "Unable to publish entity: #{e.message}",
              :alert
            )
          end

          # ==========================================================
          # ARCHIVE
          # ==========================================================

          def archive
            ::Ecosystems::LoadSources::Entity::EntityLifecycle.archive!(
              entity: @entity,
              actor: current_user
            )

            redirect_to_entity(
              "Entity archived successfully."
            )

          rescue ::Ecosystems::LoadSources::Entity::EntityLifecycle::InvalidState => e

            redirect_to_entity(
              e.message,
              :alert
            )

          rescue ActiveRecord::RecordInvalid => e

            redirect_to_entity(
              "Unable to archive entity: #{e.message}",
              :alert
            )
          end

          # ==========================================================
          # RESTORE
          # ==========================================================

          def restore
            ::Ecosystems::LoadSources::Entity::EntityLifecycle.restore!(
              entity: @entity,
              actor: current_user
            )

            redirect_to_entity(
              "Entity restored successfully."
            )

          rescue ::Ecosystems::LoadSources::Entity::EntityLifecycle::InvalidState => e

            redirect_to_entity(
              e.message,
              :alert
            )

          rescue ActiveRecord::RecordInvalid => e

            redirect_to_entity(
              "Unable to restore entity: #{e.message}",
              :alert
            )
          end

          # ==========================================================
          # DEPRECATE
          # ==========================================================

          def deprecate
            ::Ecosystems::LoadSources::Entity::EntityLifecycle.deprecate!(
              entity: @entity,
              actor: current_user
            )

            redirect_to_entity(
              "Entity deprecated."
            )

          rescue ::Ecosystems::LoadSources::Entity::EntityLifecycle::InvalidState => e

            redirect_to_entity(
              e.message,
              :alert
            )

          rescue ActiveRecord::RecordInvalid => e

            redirect_to_entity(
              "Unable to deprecate entity: #{e.message}",
              :alert
            )
          end

          # ==========================================================
          # COMPARE VERSIONS
          # ==========================================================

          def compare
            @versions =
              @entity
                .entity_versions
                .order(version_number: :desc)

            @old_version =
              if params[:from_version].present?
                @versions.find_by!(
                  id: params[:from_version]
                )
              else
                @versions
                  .order(version_number: :asc)
                  .first
              end

            @new_version =
              if params[:to_version].present?
                @versions.find_by!(
                  id: params[:to_version]
                )
              else
                @versions
                  .order(version_number: :desc)
                  .first
              end

            if @old_version && @new_version
              result =
                ::Ecosystems::LoadSources::Entity::EntityVersionDiff.call(
                  old_version: @old_version,
                  new_version: @new_version
                )

              @diff =
                ::Ecosystems::LoadSources::Entity::EntityVersionDiff.serialize(
                  result
                )
            else
              @diff = {
                nodes: [],
                summary: {
                  total: 0,
                  changed: 0,
                  added: 0,
                  removed: 0,
                  reordered: 0,
                  unchanged: 0,
                  changes: 0
                }
              }
            end

          rescue ActiveRecord::RecordNotFound
            redirect_to_entity(
              "The selected versions could not be found.",
              :alert
            )
          end

          # ==========================================================
          # HISTORY
          # ==========================================================

          def history
            @versions =
              ::Ecosystems::LoadSources::Entity::EntityVersion
                .where(entity_id: @entity.id)
                .order(version_number: :desc)

            content =
              render_to_string(
                template:
                  "admin/ecosystems/load_sources/entities/entities/history",
                layout: false
              )

            render(
              template:
                "admin/ecosystems/load_sources/entity_templates/layout/entity_templates_layout",
              layout: false,
              locals: {
                content: content
              }
            )
          end

          # ==========================================================
          # SCHEDULE PUBLISH
          # ==========================================================

          def schedule_publish
            policy =
              ::Ecosystems::LoadSources::EntityPolicy.new(
                current_user,
                @entity
              )

            unless policy.schedule_publish?
              redirect_to_entity(
                "You are not allowed to schedule publication.",
                :alert
              )

              return
            end

            publish_at =
              Time.zone.parse(
                params.require(:publish_at)
              )

            ::Ecosystems::LoadSources::Entities::ScheduleEntityPublish.call!(
              entity: @entity,
              actor: current_user,
              publish_at: publish_at
            )

            redirect_to_entity(
              "Entity publication scheduled successfully."
            )

          rescue ArgumentError => e

            redirect_to_entity(
              e.message,
              :alert
            )
          end

          private

          # ==========================================================
          # VERSION LOOKUP
          # ==========================================================

          def find_comparison_version(version_id)
            return nil if version_id.blank?

            @versions.find do |version|
              version.id.to_s == version_id.to_s
            end
          end

          def build_version_comparison(version_a, version_b)
            snapshot_a =
              normalize_snapshot(version_a.snapshot)

            snapshot_b =
              normalize_snapshot(version_b.snapshot)

            keys =
              (
                snapshot_a.keys +
                  snapshot_b.keys
              ).map(&:to_s).uniq.sort

            fields =
              keys.map do |key|
                value_a =
                  snapshot_a[key]

                value_b =
                  snapshot_b[key]

                status =
                  comparison_status(
                    value_a,
                    value_b,
                    snapshot_a.key?(key),
                    snapshot_b.key?(key)
                  )

                {
                  key: key,
                  label: key.humanize,
                  status: status,
                  old_value: value_a,
                  new_value: value_b,
                  old_present: snapshot_a.key?(key),
                  new_present: snapshot_b.key?(key),
                  nested: value_a.is_a?(Hash) ||
                    value_b.is_a?(Hash) ||
                    value_a.is_a?(Array) ||
                    value_b.is_a?(Array)
                }
              end

            changed =
              fields.count do |field|
                field[:status] != :unchanged
              end

            {
              fields: fields,
              total: fields.length,
              changed: changed,
              unchanged: fields.length - changed,
              added: fields.count { |field| field[:status] == :added },
              removed: fields.count { |field| field[:status] == :removed },
              modified: fields.count { |field| field[:status] == :modified },
              change_percentage:
                if fields.empty?
                  0
                else
                  ((changed.to_f / fields.length) * 100).round
                end
            }
          end

          def normalize_snapshot(snapshot)
            value =
              snapshot.presence || {}

            case value
            when Hash
              value.deep_stringify_keys
            else
              {}
            end
          end

          def comparison_status(
            old_value,
            new_value,
            old_present,
            new_present
          )
            return :added unless old_present
            return :removed unless new_present

            if old_value == new_value
              :unchanged
            else
              :modified
            end
          end

          # ==========================================================
          # VERSION LOOKUP
          # ==========================================================

          def find_requested_version(version_id)
            return nil if version_id.blank?

            @versions.find do |version|
              version.id.to_s == version_id.to_s
            end
          end

          # ==========================================================
          # VERSION LOOKUP
          # ==========================================================

          def find_version_for_entity(version_id)
            return nil if version_id.blank?

            ::Ecosystems::LoadSources::Entity::EntityVersion
              .where(entity_id: @entity.id)
              .find_by(id: version_id)
          end

          # ==========================================================
          # EDITORIAL CONTENT
          # ==========================================================

          def editorial_content_attribute?(attribute)
            %w[
              name
              slug
              entity_type_id
              entity_template_id
              entity_template_version_id
              summary
              scope
              metadata
              valid_from
              valid_until
              observed_at
            ].include?(attribute.to_s)
          end

          # ==========================================================
          # EVENTS
          # ==========================================================

          def record_event(
            event_type,
            entity_version: nil,
            metadata: {}
          )
            record_event_for(
              @entity,
              event_type,
              entity_version: entity_version,
              metadata: metadata
            )
          end

          def record_event_for(
            entity,
            event_type,
            entity_version: nil,
            metadata: {}
          )
            ::Ecosystems::LoadSources::Entity::EntityEvent.record!(
              entity: entity,
              entity_version: entity_version,
              event_type: event_type,
              actor: current_user,
              metadata: metadata
            )
          end

          # ==========================================================
          # ACTOR
          # ==========================================================

          def current_actor_id
            return nil unless respond_to?(:current_user)

            user =
              current_user

            return nil unless user

            user.respond_to?(:id) ? user.id : nil
          end

          # ==========================================================
          # REDIRECT HELPERS
          # ==========================================================

          def redirect_to_entity(
            message,
            type = :notice
          )
            redirect_to(
              admin_ecosystems_load_sources_entity_path(@entity),
              type => message
            )
          end

          # ==========================================================
          # SEARCH
          # ==========================================================

          def search_entities
            query =
              params[:q].to_s.strip.presence || "*"

            options = {
              fields: [
                "name",
                "slug",
                "summary"
              ],

              where: search_filters,

              aggs: {
                status: {
                  limit: 20
                },

                workflow_state: {
                  limit: 20
                },

                scope: {
                  limit: 20
                },

                entity_type_id: {
                  limit: 100
                },

                entity_template_id: {
                  limit: 100
                }
              },

              order: search_order,

              page: normalized_page,

              per_page: normalized_per_page,

              includes: [
                :entity_type,
                :entity_template
              ]
            }

            ::Ecosystems::LoadSources::Entity::Entity.search(
              query,
              **options
            )
          end

          # ==========================================================
          # SEARCH FILTERS
          # ==========================================================

          def search_filters
            filters = {}

            if params[:status].present?
              filters[:status] =
                params[:status]
            end

            if params[:workflow_state].present?
              filters[:workflow_state] =
                params[:workflow_state]
            end

            if params[:scope].present?
              filters[:scope] =
                params[:scope]
            end

            if params[:entity_type_id].present?
              filters[:entity_type_id] =
                params[:entity_type_id].to_i
            end

            if params[:entity_template_id].present?
              filters[:entity_template_id] =
                params[:entity_template_id].to_i
            end

            filters
          end

          # ==========================================================
          # SORTING
          # ==========================================================

          def search_order
            case params[:sort].to_s
            when "name"
              {
                "name.keyword": :asc
              }

            when "updated"
              {
                updated_at: :desc
              }

            when "created"
              {
                created_at: :desc
              }

            else
              {
                _score: :desc,
                updated_at: :desc
              }
            end
          end

          # ==========================================================
          # FACETS
          # ==========================================================

          def build_facets(results)
            aggregations =
              results.aggs || {}

            {
              statuses:
                facet_buckets(
                  aggregations["status"]
                ),

              workflow_states:
                facet_buckets(
                  aggregations["workflow_state"]
                ),

              scopes:
                facet_buckets(
                  aggregations["scope"]
                ),

              entity_types:
                facet_buckets(
                  aggregations["entity_type_id"]
                ),

              entity_templates:
                facet_buckets(
                  aggregations["entity_template_id"]
                )
            }
          end

          def facet_buckets(aggregation)
            return [] unless aggregation

            buckets =
              aggregation["buckets"] ||
                aggregation[:buckets]

            return [] unless buckets

            buckets.map do |bucket|
              {
                key:
                  bucket["key"] ||
                    bucket[:key],

                count:
                  bucket["doc_count"] ||
                    bucket[:doc_count]
              }
            end
          end

          # ==========================================================
          # PAGINATION
          # ==========================================================

          def normalized_page
            page =
              params[:page].to_i

            page = 1 if page < 1

            page
          end

          def normalized_per_page
            requested =
              params[:per_page].to_i

            allowed =
              [10, 25, 50, 100]

            if allowed.include?(requested)
              requested
            else
              25
            end
          end

          # ==========================================================
          # RECORD
          # ==========================================================

          def set_entity
            @entity =
              ::Ecosystems::LoadSources::Entity::Entity.find(
                params[:id]
              )
          end

          # ==========================================================
          # STRONG PARAMS
          # ==========================================================

          def entity_params
            params.require(:entity).permit(
              :name,
              :slug,
              :entity_type_id,
              :entity_template_id,
              :entity_template_version_id,
              :status,
              :scope,
              :summary,
              :metadata,
              :valid_from,
              :valid_until,
              :observed_at
            )
          end


          # ==========================================================
          # COMPARISON
          # ==========================================================

          def build_version_comparison(version_a, version_b)
            left =
              normalize_snapshot(version_a.snapshot)

            right =
              normalize_snapshot(version_b.snapshot)

            differences =
              compare_nodes(
                left,
                right
              )

            changed =
              differences.count do |item|
                item[:change_type] == :changed
              end

            added =
              differences.count do |item|
                item[:change_type] == :added
              end

            removed =
              differences.count do |item|
                item[:change_type] == :removed
              end

            unchanged =
              differences.count do |item|
                item[:change_type] == :unchanged
              end

            {
              version_a: version_a,
              version_b: version_b,

              differences: differences,

              total: differences.length,
              changed: changed,
              added: added,
              removed: removed,
              unchanged: unchanged,

              changed_percentage:
                percentage(
                  changed,
                  differences.length
                ),

              added_percentage:
                percentage(
                  added,
                  differences.length
                ),

              removed_percentage:
                percentage(
                  removed,
                  differences.length
                )
            }
          end

          # ==========================================================
          # NORMALIZATION
          # ==========================================================

          def normalize_snapshot(snapshot)
            value =
              if snapshot.respond_to?(:to_h)
                snapshot.to_h
              else
                snapshot
              end

            deep_normalize(value)
          end

          def deep_normalize(value)
            case value
            when Hash
              value.each_with_object({}) do |(key, child), result|
                result[key.to_s] =
                  deep_normalize(child)
              end

            when Array
              value.map do |child|
                deep_normalize(child)
              end

            else
              value
            end
          end

          # ==========================================================
          # RECURSIVE COMPARISON
          # ==========================================================

          def compare_nodes(left, right)
            rows = []

            compare_hash_or_value(
              left,
              right,
              path: nil,
              rows: rows
            )

            rows
          end

          def compare_hash_or_value(
            left,
            right,
            path:,
            rows:
          )
            if left.is_a?(Hash) && right.is_a?(Hash)

              keys =
                (
                  left.keys +
                    right.keys
                ).uniq.sort_by(&:to_s)

              keys.each do |key|

                child_path =
                  append_path(
                    path,
                    key
                  )

                left_present =
                  left.key?(key)

                right_present =
                  right.key?(key)

                if left_present && right_present

                  compare_hash_or_value(
                    left[key],
                    right[key],
                    path: child_path,
                    rows: rows
                  )

                elsif left_present

                  rows << comparison_row(
                    path: child_path,
                    old_value: left[key],
                    new_value: nil,
                    change_type: :removed
                  )

                  append_descendant_rows(
                    left[key],
                    child_path,
                    rows,
                    :removed
                  )

                else

                  rows << comparison_row(
                    path: child_path,
                    old_value: nil,
                    new_value: right[key],
                    change_type: :added
                  )

                  append_descendant_rows(
                    right[key],
                    child_path,
                    rows,
                    :added
                  )

                end
              end

              return
            end

            if left.is_a?(Array) && right.is_a?(Array)

              compare_arrays(
                left,
                right,
                path: path,
                rows: rows
              )

              return
            end

            if left == right

              rows << comparison_row(
                path: path,
                old_value: left,
                new_value: right,
                change_type: :unchanged
              )

            else

              rows << comparison_row(
                path: path,
                old_value: left,
                new_value: right,
                change_type: :changed
              )

            end
          end

          # ==========================================================
          # ARRAY COMPARISON
          # ==========================================================

          def compare_arrays(
            left,
            right,
            path:,
            rows:
          )
            max_length =
              [left.length, right.length].max

            max_length.times do |index|

              child_path =
                append_path(
                  path,
                  "[#{index}]"
                )

              if index >= left.length

                rows << comparison_row(
                  path: child_path,
                  old_value: nil,
                  new_value: right[index],
                  change_type: :added
                )

              elsif index >= right.length

                rows << comparison_row(
                  path: child_path,
                  old_value: left[index],
                  new_value: nil,
                  change_type: :removed
                )

              else

                compare_hash_or_value(
                  left[index],
                  right[index],
                  path: child_path,
                  rows: rows
                )

              end
            end
          end

          # ==========================================================
          # DESCENDANT ROWS
          # ==========================================================

          def append_descendant_rows(
            value,
            parent_path,
            rows,
            change_type
          )
            case value

            when Hash

              value.each do |key, child|

                path =
                  append_path(
                    parent_path,
                    key
                  )

                rows << comparison_row(
                  path: path,
                  old_value:
                    change_type == :removed ? child : nil,
                  new_value:
                    change_type == :added ? child : nil,
                  change_type: change_type
                )

                append_descendant_rows(
                  child,
                  path,
                  rows,
                  change_type
                )
              end

            when Array

              value.each_with_index do |child, index|

                path =
                  append_path(
                    parent_path,
                    "[#{index}]"
                  )

                rows << comparison_row(
                  path: path,
                  old_value:
                    change_type == :removed ? child : nil,
                  new_value:
                    change_type == :added ? child : nil,
                  change_type: change_type
                )

                append_descendant_rows(
                  child,
                  path,
                  rows,
                  change_type
                )
              end
            end
          end

          # ==========================================================
          # ROW BUILDING
          # ==========================================================

          def comparison_row(
            path:,
            old_value:,
            new_value:,
            change_type:
          )
            {
              path: path.to_s,
              old_value: old_value,
              new_value: new_value,
              change_type: change_type,

              old_display:
                format_comparison_value(old_value),

              new_display:
                format_comparison_value(new_value),

              depth:
                path.to_s.count(".") +
                  path.to_s.scan(/\[/).length
            }
          end

          # ==========================================================
          # VALUE FORMATTING
          # ==========================================================

          def format_comparison_value(value)
            case value

            when nil
              "—"

            when String
              value

            when Numeric, TrueClass, FalseClass
              value.to_s

            when Hash, Array
              JSON.pretty_generate(value)

            else
              value.to_s
            end
          end

          # ==========================================================
          # PATH
          # ==========================================================

          def append_path(parent, child)
            return child.to_s if parent.blank?

            if child.to_s.start_with?("[")
              "#{parent}#{child}"
            else
              "#{parent}.#{child}"
            end
          end

          # ==========================================================
          # PERCENTAGE
          # ==========================================================

          def percentage(value, total)
            return 0 if total.zero?

            (
              value.to_f /
                total.to_f *
                100
            ).round
          end

          # ==========================================================
          # EMPTY STATE
          # ==========================================================

          def empty_comparison
            {
              version_a: nil,
              version_b: nil,
              differences: [],
              total: 0,
              changed: 0,
              added: 0,
              removed: 0,
              unchanged: 0,
              changed_percentage: 0,
              added_percentage: 0,
              removed_percentage: 0
            }
          end

        end

      end
    end
  end
end