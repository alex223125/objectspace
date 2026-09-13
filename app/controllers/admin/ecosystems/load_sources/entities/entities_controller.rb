# frozen_string_literal: true
module Admin
  module Ecosystems
    module LoadSources
      module Entities
        class EntitiesController < ApplicationController
          before_action :set_entity, only: %i[
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
          # CRUD
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
              status: :unprocessable_entity,
              locals: {
                content: content
              }
            )
          end

          def new
            @entity =
              ::Ecosystems::LoadSources::Entity::Entity.new(
                status: "draft"
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


          def create
            @entity =
              ::Ecosystems::LoadSources::Entity::Entity.new(
                entity_params
              )

            @entity.status ||= :draft
            @entity.scope ||= :conceptual

            if @entity.save
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

          def edit
            @entity =
              ::Ecosystems::LoadSources::Entity::Entity.find(params[:id])

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
              status: :unprocessable_entity,
              locals: {
                content: content
              }
            )
          end


          def update
            if @entity.update(entity_params)
              redirect_to(
                admin_ecosystems_load_sources_entity_path(@entity),
                notice: "Entity updated successfully."
              )
            else
              render :edit, status: :unprocessable_entity
            end
          end

          def destroy
            @entity.destroy!

            redirect_to(
              admin_ecosystems_load_sources_entities_path,
              notice: "Entity deleted successfully."
            )
          end

          # ==========================================================
          # LIFECYCLE / COMMAND ACTIONS
          # ==========================================================

          def clone
            cloned_entity = @entity.dup

            cloned_entity.name = "#{@entity.name} Copy"
            cloned_entity.slug = nil
            cloned_entity.status = "draft"

            if cloned_entity.save
              redirect_to(
                admin_ecosystems_load_sources_entity_path(cloned_entity),
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

          def archive
            if @entity.update(status: "archived")
              redirect_to(
                admin_ecosystems_load_sources_entity_path(@entity),
                notice: "Entity archived."
              )
            else
              redirect_to(
                admin_ecosystems_load_sources_entity_path(@entity),
                alert: "Unable to archive entity."
              )
            end
          end

          def restore
            if @entity.update(status: "draft")
              redirect_to(
                admin_ecosystems_load_sources_entity_path(@entity),
                notice: "Entity restored to draft."
              )
            else
              redirect_to(
                admin_ecosystems_load_sources_entity_path(@entity),
                alert: "Unable to restore entity."
              )
            end
          end

          def publish
            if @entity.update(status: "published")
              redirect_to(
                admin_ecosystems_load_sources_entity_path(@entity),
                notice: "Entity published."
              )
            else
              redirect_to(
                admin_ecosystems_load_sources_entity_path(@entity),
                alert: "Unable to publish entity."
              )
            end
          end

          def deprecate
            if @entity.update(status: "deprecated")
              redirect_to(
                admin_ecosystems_load_sources_entity_path(@entity),
                notice: "Entity deprecated."
              )
            else
              redirect_to(
                admin_ecosystems_load_sources_entity_path(@entity),
                alert: "Unable to deprecate entity."
              )
            end
          end

          def compare
            @other_entities =
              ::Ecosystems::LoadSources::Entity::Entity
                .where.not(id: @entity.id)
                .order(:name)
          end

          private

          # ==========================================================
          # ELASTICSEARCH SEARCH
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
              filters[:status] = params[:status]
            end

            if params[:scope].present?
              filters[:scope] = params[:scope]
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
                name: :asc
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
        end
      end
    end

  end
end