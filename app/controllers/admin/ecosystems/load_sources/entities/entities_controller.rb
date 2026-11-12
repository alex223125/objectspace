# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        class EntitiesController < ::AdminController

          include Admin::Ecosystems::LoadSources::Entities::EcosystemAnalyticsHelper
          include Admin::Ecosystems::LoadSources::Entities::EcosystemGraphHelper
          include Admin::Ecosystems::LoadSources::Entities::EcosystemRelationshipHelper
          include Admin::Ecosystems::LoadSources::Entities::EcosystemRelationshipGraphHelper

          helper Admin::Ecosystems::LoadSources::Entities::EcosystemAnalyticsHelper
          helper Admin::Ecosystems::LoadSources::Entities::EcosystemGraphHelper
          helper Admin::Ecosystems::LoadSources::Entities::EcosystemRelationshipGraphHelper
          helper Admin::Ecosystems::LoadSources::Entities::EcosystemRelationshipGraphIntegrationHelper



          before_action :prepare_ecosystem_graph,
                        only: %i[
                  index
                  show
                ]

          before_action :set_entity,
                        only: %i[
                show edit update destroy clone archive restore
                publish deprecate compare history version
                schedule_publish cancel_schedule hover_card
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

            @entity_total = @search_results.total_count
            @current_page = normalized_page
            @per_page = normalized_per_page

            @total_pages =
              if @entity_total.zero?
                1
              else
                (@entity_total.to_f / @per_page).ceil
              end

            @facets = build_facets(@search_results)


            @ecosystem_analytics_entities =
              ecosystem_analytics_collection(
                @entities
              )

            @ecosystem_relationship_graph =
              ecosystem_relationship_graph(
                @entities
              )

            @ecosystem_relationship_graph =
              ecosystem_graph_data(
                @entities
              )

            @ecosystem_graph_payload =
              ecosystem_graph_payload(
                @entities,
                ecosystem_graph_relationships
              )


            build_ecosystem_graph_data


            @ecosystem_graph_data =
              ecosystem_graph_demo_data


            # ==== new soluton for graph
            @entities =
              ::Ecosystems::LoadSources::Entity::Entity
                .yield_self do |scope|
                if @entity&.id.present?
                  scope.where.not(id: @entity.id)
                else
                  scope
                end
              end
                .includes(
                  :entity_type,
                  :entity_template
                )

            @cross_entity_intelligence_service =
              ::Ecosystems::LoadSources::Entity::CrossEntityIntelligence.new(
                @entities
              )

            @cross_entity_intelligence =
              @cross_entity_intelligence_service.dashboard

            @cross_entity_intelligence_for_entity =
              if @entity.present?
                @cross_entity_intelligence_service.for_entity(@entity)
              else
                nil
              end

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
              locals: { content: content }
            )
          end

          def intelligence
            @intelligence = {
              totals: {},
              signals: [],
              strongest_relationships: [],
              isolated_entities: [],
              hotspots: []
            }

            render :intelligence
          end



          # ==========================================================
          # ENTITY HOVER CARD
          # ==========================================================

          def hover_card
            render partial: "admin/ecosystems/load_sources/entities/entities/hover_card",
                   locals: { entity: @entity },
                   layout: false
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
              locals: { content: content }
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
              locals: { content: content }
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
                locals: { content: content }
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
              locals: { content: content }
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
                    workflow_state: @entity.workflow_state
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
          # VERSION
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
              locals: { content: content }
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

            if cloned_entity.respond_to?(:current_version_id)
              cloned_entity.current_version_id = nil
            end

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
            redirect_to_entity(e.message, :alert)
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
            redirect_to_entity(e.message, :alert)
          rescue ::Ecosystems::LoadSources::Entity::EntityLifecycle::ValidationError => e
            redirect_to_entity(e.message, :alert)
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
            redirect_to_entity(e.message, :alert)
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
            redirect_to_entity(e.message, :alert)
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
            redirect_to_entity(e.message, :alert)
          rescue ActiveRecord::RecordInvalid => e
            redirect_to_entity(
              "Unable to deprecate entity: #{e.message}",
              :alert
            )
          end

          # ==========================================================
          # COMPARE
          # ==========================================================

          def compare
            @versions =
              @entity
                .entity_versions
                .order(version_number: :asc)

            @old_version =
              requested_or_default_old_version

            @new_version =
              requested_or_default_new_version

            if @old_version && @new_version
              configuration =
                if @entity.entity_template.present?
                  ::Ecosystems::LoadSources::Entity::DiffIntelligence::ConfigurationRepository
                    .new(@entity.entity_template)
                    .load
                else
                  ::Ecosystems::LoadSources::Entity::DiffIntelligence::Configuration.empty
                end

              result =
                ::Ecosystems::LoadSources::Entity::EntityVersionDiff.call(
                  old_version: @old_version,
                  new_version: @new_version,
                  configuration: configuration
                )

              @comparison_insight =
                ::Ecosystems::LoadSources::Entity::DiffIntelligence::BuildComparisonInsight
                  .call(
                    result: result
                  )

              semantic_facts =
                extract_application_facts(result)

              @diff =
                ::Ecosystems::LoadSources::Entity::ApplicationDiff.call(
                  facts: semantic_facts
                )

              @diff_payload =
                ::Ecosystems::LoadSources::Entity::DiffIntelligence::ApplicationDiffPayload.call(
                  diff: @diff,
                  old_version: @old_version,
                  new_version: @new_version,
                  insight: @comparison_insight
                )
            else
              @diff =
                ::Ecosystems::LoadSources::Entity::ApplicationDiff.call(
                  facts: []
                )

              @diff_payload =
                ::Ecosystems::LoadSources::Entity::DiffIntelligence::ApplicationDiffPayload.call(
                  diff: @diff,
                  old_version: @old_version,
                  new_version: @new_version,
                  insight: nil
                )
            end



            @comparison_intelligence =
              ComparisonIntelligence
                .new(@comparison_payload)
                .call

            @comparison_timeline_payload =
              build_comparison_timeline_payload(
                entity: @entity,
                old_version: @old_version,
                new_version: @new_version
              )

            @ecosystem_graph_nodes = ecosystem_graph_nodes(@entities)
            @ecosystem_graph_edges = ecosystem_graph_edges(@entities)

            ##########################################################
            @entities =
              @entity.ecosystem.entities

            @ecosystem_graph_entities =
              ecosystem_graph_entities(
                @entities
              )

            @ecosystem_graph_relationships =
              ecosystem_graph_relationships(
                @entity_relationships
              )
            ##########################################################

            @entities = @entity.ecosystem.entities

            @ecosystem_analytics_entities =
              ecosystem_analytics_collection(
                @entities
              )

            @ecosystem_relationship_graph =
              ecosystem_relationship_graph_data(
                @entities
              )


            @ecosystem_graph_nodes =
              ecosystem_graph_nodes(
                @entities
              )

            @ecosystem_graph_edges =
              ecosystem_graph_edges(
                @entities
              )

            ##########################################################

            if Rails.env.development?
              @ecosystem_relationship_graph = {
                nodes: [
                  {
                    id: "problem-1",
                    name: "Data Integrity",
                    category: "Problem",
                    activity: 18,
                    changes: 18,
                    warnings: 2,
                    evolution: 72
                  },
                  {
                    id: "method-1",
                    name: "Validation Pipeline",
                    category: "Method",
                    activity: 14,
                    changes: 14,
                    warnings: 1,
                    evolution: 64
                  },
                  {
                    id: "algorithm-1",
                    name: "Adaptive Search",
                    category: "Algorithm",
                    activity: 11,
                    changes: 11,
                    warnings: 0,
                    evolution: 81
                  },
                  {
                    id: "architecture-1",
                    name: "Distributed Architecture",
                    category: "Architecture",
                    activity: 22,
                    changes: 22,
                    warnings: 3,
                    evolution: 77
                  },
                  {
                    id: "technology-1",
                    name: "Knowledge Graph",
                    category: "Technology",
                    activity: 9,
                    changes: 9,
                    warnings: 0,
                    evolution: 59
                  }
                ],

                edges: [
                  {
                    id: "edge-1",
                    source: "problem-1",
                    target: "method-1",
                    type: "solves",
                    label: "Solved by",
                    weight: 3
                  },
                  {
                    id: "edge-2",
                    source: "method-1",
                    target: "algorithm-1",
                    type: "implements",
                    label: "Implements",
                    weight: 2
                  },
                  {
                    id: "edge-3",
                    source: "algorithm-1",
                    target: "architecture-1",
                    type: "supports",
                    label: "Supports",
                    weight: 2
                  },
                  {
                    id: "edge-4",
                    source: "architecture-1",
                    target: "technology-1",
                    type: "uses",
                    label: "Uses",
                    weight: 2
                  },
                  {
                    id: "edge-5",
                    source: "technology-1",
                    target: "problem-1",
                    type: "addresses",
                    label: "Addresses",
                    weight: 1
                  }
                ]
              }
            else
              @ecosystem_relationship_graph =
                ecosystem_relationship_graph(
                  @entities
                )
            end

            ##########################################################

            content =
              render_to_string(
                template:
                  "admin/ecosystems/load_sources/entities/entities/compare",
                layout: false
              )

            render(
              template:
                "admin/ecosystems/load_sources/entity_templates/layout/entity_templates_layout",
              layout: false,
              locals: { content: content }
            )
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
              locals: { content: content }
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
            redirect_to_entity(e.message, :alert)
          end

          private




          def ecosystem_graph_nodes(entities)
            Array(entities).each_with_index.map do |entity, index|
              ecosystem_graph_node(entity, index)
            end
          end

          def ecosystem_graph_edges(entities)
            []
          end

          def prepare_ecosystem_graph
            existing_entities =
              if defined?(@entities) && @entities.present?
                @entities
              elsif respond_to?(:entities, true)
                entities
              else
                []
              end

            @ecosystem_graph_nodes =
              ecosystem_graph_nodes(
                existing_entities
              )

            # ---------------------------------------------------------
            # IMPORTANT:
            #
            # Connect this to YOUR existing relationship collection.
            #
            # Examples:
            #
            # @relationships =
            #   @ecosystem.relationships
            #
            # or:
            #
            # @relationships =
            #   @entity.relationships
            #
            # or:
            #
            # @relationships =
            #   EcosystemRelationship.where(...)
            #
            # ---------------------------------------------------------

            existing_relationships =
              if defined?(@relationships) &&
                @relationships.present?

                @relationships

              elsif defined?(@ecosystem_relationships) &&
                @ecosystem_relationships.present?

                @ecosystem_relationships

              else

                []

              end

            @ecosystem_graph_edges =
              ecosystem_graph_edges(
                existing_relationships
              )
          end





          def prepare_ecosystem_relationship_graph
            @ecosystem_relationship_graph =
              ecosystem_relationship_graph(
                @entities
              )
          end

          # ==========================================================
          # APPLICATION DIFF
          # ==========================================================
          def build_application_diff(old_version, new_version)
            return empty_application_diff unless old_version && new_version

            configuration =
              if @entity.entity_template.present?
                ::Ecosystems::LoadSources::Entity::DiffIntelligence::ConfigurationRepository
                  .new(@entity.entity_template)
                  .load
              else
                ::Ecosystems::LoadSources::Entity::DiffIntelligence::Configuration.empty
              end

            result =
              ::Ecosystems::LoadSources::Entity::EntityVersionDiff.call(
                old_version: old_version,
                new_version: new_version,
                configuration: configuration
              )

            semantic_facts =
              extract_application_facts(result)

            ::Ecosystems::LoadSources::Entity::ApplicationDiff.call(
              facts: semantic_facts
            )
          end

          def build_comparison_insight(old_version, new_version)
            return nil unless old_version && new_version

            configuration =
              if @entity.entity_template.present?
                ::Ecosystems::LoadSources::Entity::DiffIntelligence::ConfigurationRepository
                  .new(@entity.entity_template)
                  .load
              else
                ::Ecosystems::LoadSources::Entity::DiffIntelligence::Configuration.empty
              end

            result =
              ::Ecosystems::LoadSources::Entity::EntityVersionDiff.call(
                old_version: old_version,
                new_version: new_version,
                configuration: configuration
              )

            ::Ecosystems::LoadSources::Entity::DiffIntelligence::BuildComparisonInsight
              .call(
                result: result
              )
          end

          def empty_application_diff
            ::Ecosystems::LoadSources::Entity::ApplicationDiff.call(
              facts: []
            )
          end

          def extract_application_facts(result)
            if result.respond_to?(:semantic_facts)
              return result.semantic_facts
            end

            if result.respond_to?(:facts)
              return result.facts
            end

            if result.respond_to?(:to_h)
              hash = result.to_h

              return hash[:semantic_facts] if hash.key?(:semantic_facts)
              return hash["semantic_facts"] if hash.key?("semantic_facts")

              return hash[:facts] if hash.key?(:facts)
              return hash["facts"] if hash.key?("facts")
            end

            []
          end

          # ==========================================================
          # VERSION SELECTION
          # ==========================================================

          def requested_or_default_old_version
            if params[:from_version].present?
              @versions.find_by!(
                id: params[:from_version]
              )
            else
              @versions.first
            end
          end

          def requested_or_default_new_version
            if params[:to_version].present?
              @versions.find_by!(
                id: params[:to_version]
              )
            else
              @versions.last
            end
          end


          # ==========================================================
          # COMPARE HTML
          # ==========================================================

          def render_compare_html
            content =
              render_to_string(
                template:
                  "admin/ecosystems/load_sources/entities/entities/compare",
                layout: false
              )

            render(
              template:
                "admin/ecosystems/load_sources/entity_templates/layout/entity_templates_layout",
              layout: false,
              locals: { content: content }
            )
          end

          # ==========================================================
          # ENTITY
          # ==========================================================

          def set_entity
            @entity =
              ::Ecosystems::LoadSources::Entity::Entity.find(
                params[:id]
              )
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
          # REDIRECT
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
                status: { limit: 20 },
                workflow_state: { limit: 20 },
                scope: { limit: 20 },
                entity_type_id: { limit: 100 },
                entity_template_id: { limit: 100 }
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

          def search_filters
            filters = {}

            filters[:status] =
              params[:status] if params[:status].present?

            filters[:workflow_state] =
              params[:workflow_state] if params[:workflow_state].present?

            filters[:scope] =
              params[:scope] if params[:scope].present?

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

          def search_order
            case params[:sort].to_s
            when "name"
              { "name.keyword": :asc }
            when "updated"
              { updated_at: :desc }
            when "created"
              { created_at: :desc }
            else
              {
                _score: :desc,
                updated_at: :desc
              }
            end
          end

          def build_facets(results)
            aggregations =
              results.aggs || {}

            {
              statuses:
                facet_buckets(aggregations["status"]),

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
            page = params[:page].to_i
            page = 1 if page < 1
            page
          end

          def normalized_per_page
            requested = params[:per_page].to_i
            allowed = [10, 25, 50, 100]

            allowed.include?(requested) ? requested : 25
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
          # UNUSED LEGACY COMPARISON HELPERS
          # ==========================================================

          def find_comparison_version(version_id)
            return nil if version_id.blank?

            @versions.find do |version|
              version.id.to_s == version_id.to_s
            end
          end

          def find_requested_version(version_id)
            find_comparison_version(version_id)
          end

          def find_version_for_entity(version_id)
            return nil if version_id.blank?

            ::Ecosystems::LoadSources::Entity::EntityVersion
              .where(entity_id: @entity.id)
              .find_by(id: version_id)
          end

          def build_ecosystem_graph_data
            nodes = []

            Array(@entities).each_with_index do |entity, index|
              nodes << ecosystem_graph_node(
                entity,
                index: index,
                type: :entity
              )
            end

            relationships = []

            Array(@entities).each_with_index do |entity, index|
              next unless entity.respond_to?(:parent)

              parent =
                entity.parent

              next unless parent

              relationships << ecosystem_graph_relationship(
                parent,
                entity,
                type: "contains",
                strength: 1,
                index: index
              )
            end

            @ecosystem_graph_data =
              ecosystem_graph_data(
                nodes: nodes,
                relationships: relationships
              )
          end


        end
      end
    end
  end
end