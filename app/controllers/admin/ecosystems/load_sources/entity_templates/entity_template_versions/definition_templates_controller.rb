module Admin
  module Ecosystems
    module LoadSources
      module EntityTemplates
        module EntityTemplateVersions
          class DefinitionTemplatesController < ApplicationController

            before_action :set_definition_template,
                          only: %i[
                    show
                    edit
                    update
                    destroy
                    publish
                    record_usage
                  ]

            def index
              templates = DefinitionTemplate
                            .active
                            .published
                            .includes(:versions)

              templates = templates.search(params[:q])
              templates = templates.by_category(params[:category])
              templates = templates.with_tag(params[:tag])

              templates =
                case params[:sort].to_s
                when "name_asc"
                  templates.alphabetical
                when "name_desc"
                  templates.reverse_alphabetical
                when "popular"
                  templates.popular
                when "featured"
                  templates.order(featured: :desc, popularity_score: :desc)
                when "newest"
                  templates.order(created_at: :desc)
                else
                  templates.popular
                end

              render json: {
                definitions: templates.map {
                  |template|
                  DefinitionTemplateSerializer.new(template).as_json
                },
                meta: {
                  count: templates.count,
                  categories: DefinitionTemplate
                                .active
                                .published
                                .distinct
                                .order(:category)
                                .pluck(:category)
                }
              }
            end

            def show
              render json: DefinitionTemplateSerializer
                             .new(@definition_template)
                             .as_json
            end

            def new
              @definition_template = DefinitionTemplate.new
            end

            def create
              @definition_template =
                DefinitionTemplate.new(definition_template_params)

              if @definition_template.save
                create_initial_version!

                redirect_to admin_definition_templates_path,
                            notice: "Definition created successfully."
              else
                render :new,
                       status: :unprocessable_entity
              end
            end

            def edit
            end

            def update
              if @definition_template.update(definition_template_params)
                redirect_to admin_definition_templates_path,
                            notice: "Definition updated successfully."
              else
                render :edit,
                       status: :unprocessable_entity
              end
            end

            def destroy
              @definition_template.update!(
                active: false,
                status: "archived"
              )

              redirect_to admin_definition_templates_path,
                          notice: "Definition archived successfully."
            end

            def publish
              version = @definition_template.versions
                                            .where(status: "draft")
                                            .order(version: :desc)
                                            .first

              unless version
                redirect_to admin_definition_templates_path,
                            alert: "No draft version exists."
                return
              end

              version.publish!

              redirect_to admin_definition_templates_path,
                          notice: "Definition version #{version.version} published."
            end

            def record_usage
              @definition_template.record_usage!(
                event_type: params[:event_type],
                user: current_user,
                source: params[:source],
                session_id: params[:session_id],
                metadata: params[:metadata] || {}
              )

              head :no_content
            end

            private

            def set_definition_template
              @definition_template =
                DefinitionTemplate.find_by!(
                  external_id: params[:id]
                )
            end

            def definition_template_params
              params.require(:definition_template).permit(
                :external_id,
                :name,
                :slug,
                :category,
                :description,
                :icon,
                :color,
                :featured,
                :active,
                :is_new,
                :status,
                tags: [],
                metadata: {}
              )
            end

            def create_initial_version!
              @definition_template.versions.create!(
                version: 1,
                status: "draft",
                definition: {
                  "fields" => []
                }
              )
            end
          end
        end
      end
    end
  end
end