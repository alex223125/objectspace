module Admin
  module Ecosystems
    module LoadSources
      module EntityTemplates

        class EntityTemplateVersionsController < ::AdminController

          before_action :set_entity_template_version,
                        only: [
                          :show,
                          :edit,
                          :update,
                          :destroy,
                          :compare
                        ]

          before_action :set_entity_template,
                        only: [
                          :show,
                          :edit,
                          :update,
                          :destroy,
                          :new,
                          :create
                        ]


          # ============================================================
          # INDEX
          # ============================================================

          # def index
          #   @versions =
          #     @entity_template
          #       .entity_template_versions
          #       .order(version: :desc)
          # end


          def index
            @entity_template_versions =
              ::Ecosystems::LoadSources::EntityTemplates::EntityTemplateVersion
                .includes(:entity_template)
                .order(version: :desc)

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
            @version =
              @entity_template_version

            @entity_template_versions =
              @entity_template
                .entity_template_versions
                .order(version: :desc)

            content = render_to_string(
              template: "admin/ecosystems/load_sources/entity_templates/entity_template_versions/show",
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
          # NEW
          # ============================================================

          def new
            @version =
              @entity_template
                .entity_template_versions
                .build

            @version.version =
              next_version_number
          end


          # ============================================================
          # EDIT
          # ============================================================

          def edit
            @version =
              @entity_template_version
          end


          # ============================================================
          # CREATE
          # ============================================================

          def create
            @version =
              @entity_template
                .entity_template_versions
                .build(
                  entity_template_version_params
                )

            @version.version ||=
              next_version_number

            if @version.save
              redirect_to(
                admin_ecosystems_load_sources_entity_templates_entity_template_version_path(
                  @version
                ),
                notice: "Entity template version was successfully created."
              )
            else
              render :new,
                     status: :unprocessable_entity
            end
          end


          # ============================================================
          # UPDATE
          # ============================================================

          def update
            @version =
              @entity_template_version

            if @version.update(
              entity_template_version_params
            )
              redirect_to(
                admin_ecosystems_load_sources_entity_templates_entity_template_version_path(
                  @version
                ),
                notice: "Entity template version was successfully updated."
              )
            else
              render :edit,
                     status: :unprocessable_entity
            end
          end


          # ============================================================
          # DESTROY
          # ============================================================

          def destroy
            @version =
              @entity_template_version

            @version.destroy

            redirect_to(
              admin_ecosystems_load_sources_entity_templates_entity_template_versions_path,
              notice: "Entity template version was successfully deleted."
            )
          end


          # ============================================================
          # COMPARE
          # ============================================================

          def compare
            @versions =
              @entity_template
                .entity_template_versions
                .order(version: :desc)


            # ----------------------------------------------------------
            # SELECT VERSIONS
            # ----------------------------------------------------------

            @left_version =
              find_comparison_version(
                params[:left_id]
              )

            @right_version =
              find_comparison_version(
                params[:right_id]
              )


            # ----------------------------------------------------------
            # DEFAULT VERSION SELECTION
            # ----------------------------------------------------------

            if @left_version.nil? &&
              @right_version.nil?

              @right_version =
                @entity_template_version

              @left_version =
                previous_version_for(
                  @right_version
                )

            elsif @left_version.nil?

              @right_version ||=
                @entity_template_version

              @left_version =
                previous_version_for(
                  @right_version
                )

            elsif @right_version.nil?

              @right_version =
                @entity_template_version
            end


            # ----------------------------------------------------------
            # COMPARISON
            # ----------------------------------------------------------

            if @left_version.present? &&
              @right_version.present?

              comparator =
                Services::Admin::Ecosystems::LoadSources::EntityTemplates::EntityTemplateVersionComparator.new(
                  @left_version,
                  @right_version
                )

              comparison =
                comparator.compare


              # --------------------------------------------------------
              # RAW DEFINITIONS
              # --------------------------------------------------------

              raw_comparison =
                comparison[:raw] ||
                  comparison["raw"] ||
                  {}


              @left_definition =
                raw_comparison[:version_a] ||
                  raw_comparison["version_a"] ||
                  {}


              @right_definition =
                raw_comparison[:version_b] ||
                  raw_comparison["version_b"] ||
                  {}


              # --------------------------------------------------------
              # FIELD COMPARISONS
              # --------------------------------------------------------

              @field_comparisons =
                comparison[:fields] ||
                  comparison["fields"] ||
                  []


              @field_changes =
                @field_comparisons


              # --------------------------------------------------------
              # DEFINITION-LEVEL CHANGES
              # --------------------------------------------------------

              @definition_changes =
                build_definition_changes(
                  @left_definition,
                  @right_definition
                )


              # --------------------------------------------------------
              # SUMMARY
              # --------------------------------------------------------

              raw_summary =
                comparison[:summary] ||
                  comparison["summary"] ||
                  {}


              @comparison_summary =
                {
                  added:
                    raw_summary[:added] ||
                      raw_summary["added"] ||
                      0,

                  removed:
                    raw_summary[:removed] ||
                      raw_summary["removed"] ||
                      0,

                  changed:
                    raw_summary[:modified] ||
                      raw_summary["modified"] ||
                      0,

                  unchanged:
                    raw_summary[:unchanged] ||
                      raw_summary["unchanged"] ||
                      0
                }


              # --------------------------------------------------------
              # STIMULUS PAYLOAD
              # --------------------------------------------------------

              @field_comparisons_json =
                @field_comparisons.map do |field|

                  field_hash =
                    field.is_a?(Hash) ? field : {}


                  changes =
                    field_hash[:changes] ||
                      field_hash["changes"] ||
                      {}


                  normalized_changes =
                    if changes.is_a?(Hash)

                      changes.map do |attribute, change|

                        change_hash =
                          change.is_a?(Hash) ?
                            change :
                            {}


                        {
                          key: attribute.to_s,

                          from:
                            change_hash[:from] ||
                              change_hash["from"],

                          to:
                            change_hash[:to] ||
                              change_hash["to"],

                          from_text:
                            format_comparison_value(
                              change_hash[:from] ||
                                change_hash["from"]
                            ),

                          to_text:
                            format_comparison_value(
                              change_hash[:to] ||
                                change_hash["to"]
                            )
                        }

                      end

                    elsif changes.is_a?(Array)

                      changes.map do |change|

                        change_hash =
                          change.is_a?(Hash) ?
                            change :
                            {}


                        {
                          key:
                            (
                              change_hash[:key] ||
                                change_hash["key"] ||
                                change_hash[:name] ||
                                change_hash["name"]
                            ).to_s,

                          from:
                            change_hash[:from] ||
                              change_hash["from"] ||
                              change_hash[:left] ||
                              change_hash["left"],

                          to:
                            change_hash[:to] ||
                              change_hash["to"] ||
                              change_hash[:right] ||
                              change_hash["right"],

                          from_text:
                            format_comparison_value(
                              change_hash[:from] ||
                                change_hash["from"] ||
                                change_hash[:left] ||
                                change_hash["left"]
                            ),

                          to_text:
                            format_comparison_value(
                              change_hash[:to] ||
                                change_hash["to"] ||
                                change_hash[:right] ||
                                change_hash["right"]
                            )
                        }

                      end

                    else
                      []
                    end


                  {
                    name:
                      (
                        field_hash[:name] ||
                          field_hash["name"]
                      ).to_s,

                    change_type:
                      (
                        field_hash[:change_type] ||
                          field_hash["change_type"] ||
                          "unchanged"
                      ).to_s,

                    version_a_present:
                      field_hash.key?(:version_a_present) ?
                        field_hash[:version_a_present] :
                        field_hash["version_a_present"],

                    version_b_present:
                      field_hash.key?(:version_b_present) ?
                        field_hash[:version_b_present] :
                        field_hash["version_b_present"],

                    version_a:
                      field_hash[:version_a] ||
                        field_hash["version_a"],

                    version_b:
                      field_hash[:version_b] ||
                        field_hash["version_b"],

                    version_a_text:
                      field_hash[:version_a_text] ||
                        field_hash["version_a_text"],

                    version_b_text:
                      field_hash[:version_b_text] ||
                        field_hash["version_b_text"],

                    changes:
                      normalized_changes
                  }

                end

            else

              # --------------------------------------------------------
              # NO COMPARISON AVAILABLE
              # --------------------------------------------------------

              @left_definition =
                {}

              @right_definition =
                {}

              @field_comparisons =
                []

              @field_changes =
                []

              @definition_changes =
                []

              @comparison_summary =
                {
                  added: 0,
                  removed: 0,
                  changed: 0,
                  unchanged: 0
                }

              @field_comparisons_json =
                []
            end

            content = render_to_string(
              template: "admin/ecosystems/load_sources/entity_templates/entity_template_versions/compare",
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


          private


          # ============================================================
          # ENTITY TEMPLATE VERSION
          # ============================================================
          #
          # The version is identified by params[:id].
          #
          # Example:
          #
          # /entity_template_versions/2
          #
          # gives:
          #
          # params[:id] == "2"
          #
          # ============================================================

          def set_entity_template_version
            @entity_template_version =
              ::Ecosystems::LoadSources::EntityTemplates::EntityTemplateVersion.find(
                params[:id]
              )
          end


          # ============================================================
          # ENTITY TEMPLATE
          # ============================================================
          #
          # EntityTemplateVersion belongs_to EntityTemplate, so derive
          # the template from the version instead of expecting
          # params[:entity_template_id].
          #
          # ============================================================

          def set_entity_template
            @entity_template =
              if @entity_template_version.present?
                @entity_template_version.entity_template
              else
                find_entity_template_for_collection_action
              end

            return if @entity_template.present?
            #
            # raise ActiveRecord::RecordNotFound,
            #       "Could not determine the EntityTemplate for this request."
          end


          # ============================================================
          # COLLECTION ENTITY TEMPLATE
          # ============================================================
          #
          # For collection actions such as index/new/create there is no
          # entity_template_version ID.
          #
          # Your current routes also do not nest versions under an
          # entity_template ID, so params[:entity_template_id] cannot be
          # used reliably here.
          #
          # If index/new/create are accessed through an entity template
          # route elsewhere in the application, this method can resolve
          # that parameter.
          #
          # ============================================================

          def find_entity_template_for_collection_action
            return nil if params[:entity_template_id].blank?

            ::Ecosystems::LoadSources::EntityTemplates::EntityTemplate.find_by(
              id: params[:entity_template_id]
            )
          end


          # ============================================================
          # FIND COMPARISON VERSION
          # ============================================================

          def find_comparison_version(id)
            return nil if id.blank?

            @entity_template
              .entity_template_versions
              .find_by(id: id)
          end


          # ============================================================
          # PREVIOUS VERSION
          # ============================================================

          def previous_version_for(version)
            return nil unless version.present?

            @versions =
              @versions ||
                @entity_template
                  .entity_template_versions
                  .order(version: :desc)


            versions =
              @versions.to_a


            current_index =
              versions.index do |candidate|
                candidate.id == version.id
              end


            return nil unless current_index


            versions[current_index + 1]
          end


          # ============================================================
          # DEFINITION CHANGES
          # ============================================================

          def build_definition_changes(left_definition, right_definition)
            left =
              left_definition.is_a?(Hash) ?
                left_definition :
                {}

            right =
              right_definition.is_a?(Hash) ?
                right_definition :
                {}


            keys =
              (
                left.keys +
                  right.keys
              ).map(&:to_s).uniq.sort


            keys.each_with_object([]) do |key, changes|

              next if key == "fields"


              left_value =
                fetch_hash_value(
                  left,
                  key
                )

              right_value =
                fetch_hash_value(
                  right,
                  key
                )


              next if left_value == right_value


              if !left.key?(key) &&
                !left.key?(key.to_sym)

                changes << {
                  key: key,
                  type: "added",
                  left: nil,
                  right: right_value
                }

              elsif !right.key?(key) &&
                !right.key?(key.to_sym)

                changes << {
                  key: key,
                  type: "removed",
                  left: left_value,
                  right: nil
                }

              else

                changes << {
                  key: key,
                  type: "changed",
                  left: left_value,
                  right: right_value
                }

              end
            end
          end


          # ============================================================
          # HASH VALUE
          # ============================================================

          def fetch_hash_value(hash, key)
            return nil unless hash.is_a?(Hash)

            hash[key] ||
              hash[key.to_sym]
          end


          # ============================================================
          # FORMAT COMPARISON VALUE
          # ============================================================

          def format_comparison_value(value)
            case value

            when nil
              "—"

            when true
              "true"

            when false
              "false"

            when String
              value.presence || "empty"

            when Array, Hash
              JSON.pretty_generate(value)

            else
              value.to_s

            end

          rescue StandardError
            value.to_s
          end


          # ============================================================
          # STRONG PARAMETERS
          # ============================================================

          def entity_template_version_params
            params
              .require(:entity_template_version)
              .permit(
                :version,
                :status,
                :definition
              )
          end


          # ============================================================
          # NEXT VERSION NUMBER
          # ============================================================

          def next_version_number
            latest =
              @entity_template
                .entity_template_versions
                .order(version: :desc)
                .first


            latest_version =
              latest&.version.to_i


            latest_version + 1
          end

        end

      end
    end
  end
end
