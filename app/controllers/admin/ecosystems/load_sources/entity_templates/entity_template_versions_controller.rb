# app/controllers/admin/ecosystems/load_sources/entity_templates/entity_template_versions_controller.rb

module Admin
  module Ecosystems
    module LoadSources
      module EntityTemplates
        class EntityTemplateVersionsController < ::AdminController

          EntityTemplateVersion =
            ::Ecosystems::LoadSources::EntityTemplates::EntityTemplateVersion

          EntityTemplate =
            ::Ecosystems::LoadSources::EntityTemplates::EntityTemplate


          before_action :set_entity_template_version,
                        only: [
                          :show,
                          :edit,
                          :update,
                          :destroy,
                          :publish,
                          :archive,
                          :clone,
                          :compare
                        ]

          # ============================================================
          # INDEX
          # ============================================================

          def index
            @entity_template_versions =
              ::Ecosystems::LoadSources::EntityTemplates::EntityTemplateVersion
                .includes(:entity_template)
                .order(created_at: :desc)

            content = render_to_string(
              template: "admin/ecosystems/load_sources/entity_templates/entity_template_versions/index",
              layout: false
            )

            render(
              template: "admin/ecosystems/load_sources/entity_templates/layout/entity_templates_layout",
              layout: false,
              locals: {
                content: content
              }
            )
          end


          # ============================================================
          # SHOW
          # ============================================================

          def show
          end


          # ============================================================
          # NEW
          # ============================================================

          def new
            @entity_template_version = ::Ecosystems::LoadSources::EntityTemplates::EntityTemplateVersion.new

            @entity_templates =
              EntityTemplate
                .order(:name)


            content =
              render_to_string(
                template:
                  "admin/ecosystems/load_sources/entity_templates/entity_template_versions/new",
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


          # ============================================================
          # EDIT
          # ============================================================

          def edit
            @entity_templates =
              EntityTemplate
                .order(:name)
          end


          # ============================================================
          # CREATE
          # ============================================================

          def create
            @entity_template_version =
              ::Ecosystems::LoadSources::EntityTemplates::EntityTemplateVersion
                .new(
                entity_template_version_params
              )

            if @entity_template_version.save
              redirect_to(
                admin_ecosystems_load_sources_entity_templates_entity_template_version_path(
                  @entity_template_version
                ),
                notice: "Entity template version was successfully created."
              )
            else
              @entity_templates =
                EntityTemplate
                  .order(:name)

              render :new,
                     status: :unprocessable_entity
            end
          end


          # ============================================================
          # UPDATE
          # ============================================================

          def update
            if @entity_template_version.update(
              entity_template_version_params
            )
              redirect_to(
                admin_ecosystems_load_sources_entity_templates_entity_template_version_path(
                  @entity_template_version
                ),
                notice: "Entity template version was successfully updated."
              )
            else
              @entity_templates =
                EntityTemplate
                  .order(:name)

              render :edit,
                     status: :unprocessable_entity
            end
          end


          # ============================================================
          # PUBLISH
          # ============================================================

          def publish
            if @entity_template_version.publish!
              redirect_to(
                admin_ecosystems_load_sources_entity_templates_entity_template_version_path(
                  @entity_template_version
                ),
                notice: "Entity template version was successfully published."
              )
            else
              redirect_to(
                admin_ecosystems_load_sources_entity_templates_entity_template_version_path(
                  @entity_template_version
                ),
                alert: "Entity template version could not be published."
              )
            end
          rescue ActiveRecord::RecordInvalid => e
            redirect_to(
              admin_ecosystems_load_sources_entity_templates_entity_template_version_path(
                @entity_template_version
              ),
              alert: e.record.errors.full_messages.to_sentence
            )
          end


          # ============================================================
          # ARCHIVE
          # ============================================================

          def archive
            if @entity_template_version.archive!
              redirect_to(
                admin_ecosystems_load_sources_entity_templates_entity_template_version_path(
                  @entity_template_version
                ),
                notice: "Entity template version was archived."
              )
            else
              redirect_to(
                admin_ecosystems_load_sources_entity_templates_entity_template_version_path(
                  @entity_template_version
                ),
                alert: "Entity template version could not be archived."
              )
            end
          rescue ActiveRecord::RecordInvalid => e
            redirect_to(
              admin_ecosystems_load_sources_entity_templates_entity_template_version_path(
                @entity_template_version
              ),
              alert: e.message
            )
          end

          # ============================================================
          # CLONE
          # ============================================================

          def clone
            source = @entity_template_version

            @entity_template_version =
              ::Ecosystems::LoadSources::EntityTemplates::EntityTemplateVersion
                .new(
                entity_template: source.entity_template,
                definition: source.definition.deep_dup,
                status: "draft"
              )

            if @entity_template_version.save
              redirect_to(
                admin_ecosystems_load_sources_entity_templates_entity_template_version_path(
                  @entity_template_version
                ),
                notice: "Entity template version was successfully cloned as a draft."
              )
            else
              redirect_to(
                admin_ecosystems_load_sources_entity_templates_entity_template_version_path(
                  source
                ),
                alert: "Unable to clone this entity template version."
              )
            end
          end

          # ============================================================
          # COMPARE
          # ============================================================

          def compare
            @entity_template =
              @entity_template_version.entity_template

            @versions =
              @entity_template
                .entity_template_versions
                .order(version: :desc, created_at: :desc)

            @left_version =
              if params[:left_id].present?
                @versions.find_by(id: params[:left_id])
              else
                @entity_template_version
              end

            @right_version =
              if params[:right_id].present?
                @versions.find_by(id: params[:right_id])
              else
                @versions.where.not(id: @left_version.id).first
              end

            if @left_version.nil? || @right_version.nil?
              redirect_to(
                admin_ecosystems_load_sources_entity_templates_entity_template_version_path(
                  @entity_template_version
                ),
                alert: "Two versions are required for comparison."
              )

              return
            end

            unless @left_version.entity_template_id ==
              @right_version.entity_template_id

              redirect_to(
                admin_ecosystems_load_sources_entity_templates_entity_template_version_path(
                  @entity_template_version
                ),
                alert: "Only versions belonging to the same entity template can be compared."
              )

              return
            end

            @left_definition =
              normalize_definition(
                @left_version.definition
              )

            @right_definition =
              normalize_definition(
                @right_version.definition
              )

            @definition_changes =
              build_definition_changes(
                @left_definition,
                @right_definition
              )
          end


          # ============================================================
          # DESTROY
          # ============================================================

          def destroy
            @entity_template_version.destroy!

            redirect_to(
              admin_ecosystems_load_sources_entity_templates_entity_template_versions_path,
              notice: "Entity template version was successfully deleted."
            )
          end


          private


          # ============================================================
          # FIND RECORD
          # ============================================================

          def set_entity_template_version
            @entity_template_version =
              ::Ecosystems::LoadSources::EntityTemplates::EntityTemplateVersion
                .find(params[:id])
          end


          # ============================================================
          # STRONG PARAMETERS
          # ============================================================

          def entity_template_version_params
            params.require(:entity_template_version).permit(
              :entity_template_id,
              definition: {}
            )
          end

          # ============================================================
          # NORMALIZE DEFINITION
          # ============================================================

          def normalize_definition(definition)
            case definition
            when Hash
              definition.deep_stringify_keys
            else
              {}
            end
          end


          # ============================================================
          # BUILD DEFINITION CHANGES
          #
          # Produces a simple comparison structure:
          #
          # added
          # removed
          # changed
          # unchanged
          #
          # ============================================================

          def build_definition_changes(left, right)
            keys =
              (
                left.keys +
                  right.keys
              ).uniq.sort

            keys.each_with_object([]) do |key, changes|

              left_exists =
                left.key?(key)

              right_exists =
                right.key?(key)

              if !left_exists && right_exists

                changes << {
                  key: key,
                  type: :added,
                  left: nil,
                  right: right[key]
                }

              elsif left_exists && !right_exists

                changes << {
                  key: key,
                  type: :removed,
                  left: left[key],
                  right: nil
                }

              elsif left[key] != right[key]

                changes << {
                  key: key,
                  type: :changed,
                  left: left[key],
                  right: right[key]
                }

              else

                changes << {
                  key: key,
                  type: :unchanged,
                  left: left[key],
                  right: right[key]
                }

              end

            end
          end
        end
      end
    end
  end
end
