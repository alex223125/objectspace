# app/controllers/admin/ecosystems/load_sources/entity_templates/entity_template_versions_controller.rb

module Admin
  module Ecosystems
    module LoadSources
      module EntityTemplates

        class EntityTemplateVersionsController < ::AdminController

          VERSION_MODEL =
            ::Ecosystems::LoadSources::EntityTemplates::EntityTemplateVersion

          ENTITY_TEMPLATE_MODEL =
            ::Ecosystems::LoadSources::EntityTemplates::EntityTemplate

          STATUS_VALUES = %w[
            draft
            published
            archived
          ].freeze

          SORT_COLUMNS = %w[
            version
            status
            created_at
            updated_at
            published_at
            entity_template_id
          ].freeze

          DEFAULT_SORT = "version".freeze
          DEFAULT_DIRECTION = "desc".freeze

          DEFAULT_PER_PAGE = 50
          MAX_PER_PAGE = 200


          # ============================================================
          # CALLBACKS
          # ============================================================

          before_action :set_entity_template_version,
                        only: [
                          :show,
                          :edit,
                          :update,
                          :destroy,
                          :compare,
                          :clone,
                          :publish,
                          :archive
                        ]

          before_action :set_entity_template,
                        only: [
                          :show,
                          :edit,
                          :update,
                          :destroy,
                          :new,
                          :create,
                          :compare,
                          :clone,
                          :publish,
                          :archive
                        ]


          # ============================================================
          # INDEX
          # ============================================================

          def index

            prepare_index_filters
            prepare_index_pagination

            @entity_template_versions =
              execute_search(
                build_search_scope
              )

            prepare_index_statistics
            prepare_index_metadata

            render_index

          end


          # ============================================================
          # ENTITY TEMPLATE SEARCH
          # ============================================================

          def search

            query =
              params[:q].to_s.strip

            if query.blank?

              return render(
                json: {
                  results: []
                }
              )

            end


            templates =
              ENTITY_TEMPLATE_MODEL.search(
                query,
                fields: [
                  :name,
                  :title,
                  :slug,
                  :id
                ],
                match: :word_start,
                misspellings: {
                  below: 5
                },
                limit: 20,
                load: true
              )


            results =
              templates.map do |template|

                {
                  id: template.id,
                  name: template.respond_to?(:name) ? template.name : nil,
                  title: template.respond_to?(:title) ? template.title : nil,
                  slug: template.respond_to?(:slug) ? template.slug : nil
                }

              end


            render(
              json: {
                results: results
              }
            )

          rescue Searchkick::Error => e

            Rails.logger.error(
              "[EntityTemplate Search] #{e.class}: #{e.message}"
            )

            render(
              json: {
                results: [],
                error: "Search service unavailable."
              },
              status: :service_unavailable
            )

          rescue StandardError => e

            Rails.logger.error(
              "[EntityTemplate Search] #{e.class}: #{e.message}"
            )

            render(
              json: {
                results: [],
                error: "Unable to search entity templates."
              },
              status: :internal_server_error
            )

          end


          # ============================================================
          # SHOW
          # ============================================================

          def show

            @version =
              @entity_template_version

            content =
              render_to_string(
                template:
                  "admin/ecosystems/load_sources/entity_templates/entity_template_versions/show",
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
          # NEW
          # ============================================================

          def new

            unless @entity_template.present?

              redirect_to(
                admin_ecosystems_load_sources_entity_templates_entity_templates_path,
                alert:
                  "Please select an Entity Template before creating a version."
              ) and return

            end


            load_entity_templates


            @version =
              @entity_template
                .entity_template_versions
                .build(
                  status: "draft",
                  definition: {
                    "fields" => []
                  }
                )


            @version.version =
              next_version_number


            # ----------------------------------------------------------
            # IMPORTANT
            #
            # The existing application used @version in this controller.
            # The new builder view uses @entity_template_version.
            #
            # Expose both variables so existing views/functionality
            # continue working while the new builder can use the
            # conventional @entity_template_version variable.
            # ----------------------------------------------------------

            @entity_template_version =
              @version


            render_version_form(
              "new"
            )

          end


          # ============================================================
          # EDIT
          # ============================================================

          def edit

            load_entity_templates

            @version =
              @entity_template_version


            # Keep both variables available to the views.

            @entity_template_version =
              @version


            render_version_form(
              "edit"
            )

          end


          # ============================================================
          # CREATE
          # ============================================================

          def create

            unless @entity_template.present?

              redirect_to(
                admin_ecosystems_load_sources_entity_templates_entity_templates_path,
                alert:
                  "Please select an Entity Template before creating a version."
              ) and return

            end


            definition =
              parse_definition_parameter


            # ----------------------------------------------------------
            # INVALID JSON
            # ----------------------------------------------------------

            if definition[:error].present?

              @version =
                @entity_template
                  .entity_template_versions
                  .build(
                    status: "draft"
                  )


              @version.version =
                params.dig(
                  :ecosystems_load_sources_entity_templates_entity_template_version,
                  :version
                ).presence ||
                next_version_number


              @version.status =
                params.dig(
                  :ecosystems_load_sources_entity_templates_entity_template_version,
                  :status
                ).presence ||
                "draft"


              @version.definition =
                params.dig(
                  :ecosystems_load_sources_entity_templates_entity_template_version,
                  :definition
                )


              @version.errors.add(
                :definition,
                definition[:error]
              )


              @entity_template_version =
                @version


              load_entity_templates


              return render_version_form(
                "new",
                status: :unprocessable_entity
              )

            end


            # ----------------------------------------------------------
            # BUILD VERSION
            # ----------------------------------------------------------

            version_attributes =
              version_parameters


            @version =
              @entity_template
                .entity_template_versions
                .build(
                  version_attributes
                )


            @version.definition =
              definition[:value]


            # If version was not submitted, automatically calculate it.

            @version.version =
              next_version_number if
              @version.version.blank?


            @version.status =
              "draft" if
              @version.status.blank?


            # Make the variable used by the builder view available.

            @entity_template_version =
              @version


            if @version.save

              redirect_to(
                admin_ecosystems_load_sources_entity_templates_entity_template_version_path(
                  @version
                ),
                notice:
                  "Entity template version was successfully created."
              )

            else

              load_entity_templates


              render_version_form(
                "new",
                status: :unprocessable_entity
              )

            end

          rescue ActiveRecord::RecordNotUnique

            @version ||= @entity_template
              .entity_template_versions
              .build


            @version.errors.add(
              :version,
              "could not be assigned because another version was created concurrently."
            )


            @entity_template_version =
              @version


            load_entity_templates


            render_version_form(
              "new",
              status: :unprocessable_entity
            )

          end


          # ============================================================
          # UPDATE
          # ============================================================

          def update

            definition =
              parse_definition_parameter


            if definition[:error].present?

              @entity_template_version.errors.add(
                :definition,
                definition[:error]
              )


              @version =
                @entity_template_version


              load_entity_templates


              return render_version_form(
                "edit",
                status: :unprocessable_entity
              )

            end


            @entity_template_version.assign_attributes(
              version_parameters.except(:version)
            )


            @entity_template_version.definition =
              definition[:value]


            @version =
              @entity_template_version


            if @entity_template_version.save

              redirect_to(
                admin_ecosystems_load_sources_entity_templates_entity_template_version_path(
                  @entity_template_version
                ),
                notice:
                  "Template version updated successfully."
              )

            else

              load_entity_templates


              render_version_form(
                "edit",
                status: :unprocessable_entity
              )

            end

          end


          # ============================================================
          # DESTROY
          # ============================================================

          def destroy

            if @entity_template_version.entities.exists?

              redirect_to(
                admin_ecosystems_load_sources_entity_templates_entity_template_version_path(
                  @entity_template_version
                ),
                alert:
                  "This version cannot be deleted because entities are using it."
              )

              return

            end


            @entity_template_version.destroy!


            redirect_to(
              admin_ecosystems_load_sources_entity_templates_entity_template_versions_path,
              notice:
                "Entity template version was successfully deleted."
            )

          rescue ActiveRecord::RecordNotDestroyed => e

            Rails.logger.error(
              "[EntityTemplateVersion Destroy] #{e.class}: #{e.message}"
            )


            redirect_to(
              admin_ecosystems_load_sources_entity_templates_entity_template_version_path(
                @entity_template_version
              ),
              alert:
                "Unable to delete this entity template version."
            )

          end


          # ============================================================
          # PUBLISH
          # ============================================================

          def publish

            @entity_template_version.publish!


            redirect_to(
              admin_ecosystems_load_sources_entity_templates_entity_template_version_path(
                @entity_template_version
              ),
              notice:
                "Version #{@entity_template_version.version} was published successfully."
            )

          rescue ActiveRecord::RecordInvalid => e

            redirect_to(
              admin_ecosystems_load_sources_entity_templates_entity_template_version_path(
                @entity_template_version
              ),
              alert:
                e.message
            )

          end


          # ============================================================
          # ARCHIVE
          # ============================================================

          def archive

            @entity_template_version.archive!


            redirect_to(
              admin_ecosystems_load_sources_entity_templates_entity_template_version_path(
                @entity_template_version
              ),
              notice:
                "Version #{@entity_template_version.version} was archived successfully."
            )

          rescue ActiveRecord::RecordInvalid => e

            redirect_to(
              admin_ecosystems_load_sources_entity_templates_entity_template_version_path(
                @entity_template_version
              ),
              alert:
                e.message
            )

          end


          # ============================================================
          # COMPARE
          # ============================================================

          def compare

            @versions =
              @entity_template
                .entity_template_versions
                .latest_first


            @left_version =
              find_comparison_version(
                params[:left_id]
              )


            @right_version =
              find_comparison_version(
                params[:right_id]
              )


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


            if @left_version.present? &&
              @right_version.present?

              comparator =
                Services::Admin::Ecosystems::LoadSources::EntityTemplates::EntityTemplateVersionComparator.new(
                  @left_version,
                  @right_version
                )


              comparison =
                comparator.compare


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


              @field_comparisons =
                comparison[:fields] ||
                  comparison["fields"] ||
                  []


              @field_changes =
                @field_comparisons


              @definition_changes =
                build_definition_changes(
                  @left_definition,
                  @right_definition
                )


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


              @field_comparisons_json =
                @field_comparisons.map do |field|

                  field_hash =
                    field.is_a?(Hash) ? field : {}


                  changes =
                    field_hash[:changes] ||
                      field_hash["changes"] ||
                      {}


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
                      if field_hash.key?(:version_a_present)
                        field_hash[:version_a_present]
                      else
                        field_hash["version_a_present"]
                      end,

                    version_b_present:
                      if field_hash.key?(:version_b_present)
                        field_hash[:version_b_present]
                      else
                        field_hash["version_b_present"]
                      end,

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
                      normalize_comparison_changes(
                        changes
                      )
                  }

                end

            else

              @left_definition = {}
              @right_definition = {}
              @field_comparisons = []
              @field_changes = []
              @definition_changes = []


              @comparison_summary = {
                added: 0,
                removed: 0,
                changed: 0,
                unchanged: 0
              }


              @field_comparisons_json = []

            end


            content =
              render_to_string(
                template:
                  "admin/ecosystems/load_sources/entity_templates/entity_template_versions/compare",
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
          # CLONE
          # ============================================================

          def clone

            source_version =
              @entity_template_version


            cloned_version =
              source_version.create_next_version!


            redirect_to(
              admin_ecosystems_load_sources_entity_templates_entity_template_version_path(
                cloned_version
              ),
              notice:
                "Version #{source_version.version} was cloned as draft version #{cloned_version.version}."
            )

          rescue ActiveRecord::RecordInvalid => e

            redirect_to(
              admin_ecosystems_load_sources_entity_templates_entity_template_version_path(
                source_version
              ),
              alert:
                "Unable to clone entity template version: #{e.record.errors.full_messages.to_sentence}"
            )

          rescue StandardError => e

            Rails.logger.error(
              "[EntityTemplateVersion Clone] #{e.class}: #{e.message}"
            )


            redirect_to(
              admin_ecosystems_load_sources_entity_templates_entity_template_version_path(
                source_version
              ),
              alert:
                "Unable to clone entity template version."
            )

          end


          private


          # ============================================================
          # VERSION FORM
          # ============================================================

          def render_version_form(
            action,
            status: nil
          )

            # ----------------------------------------------------------
            # Ensure the view always has the same object.
            #
            # This prevents:
            #
            # undefined method `errors' for nil:NilClass
            #
            # when new.html.erb uses:
            #
            # @entity_template_version.errors
            # ----------------------------------------------------------

            @entity_template_version ||=
              @version


            @version ||=
              @entity_template_version


            content =
              render_to_string(
                template:
                  "admin/ecosystems/load_sources/entity_templates/entity_template_versions/#{action}",
                layout: false
              )


            render(
              template:
                "admin/ecosystems/load_sources/entity_templates/layout/entity_templates_layout",
              layout: false,
              locals: {
                content: content
              },
              status: status
            )

          end


          # ============================================================
          # STRONG PARAMETERS
          # ============================================================

          def version_parameters

            permitted =
              params.fetch(
                :ecosystems_load_sources_entity_templates_entity_template_version,
                {}
              )


            permitted =
              permitted.permit(
                :version,
                :status
              )


            permitted.to_h.symbolize_keys

          end


          # ============================================================
          # INDEX FILTERS
          # ============================================================

          def prepare_index_filters

            @filters =
              {
                q: params[:q].to_s.strip,

                status:
                  normalize_status_filter(
                    params[:status]
                  ),

                entity_template_id:
                  normalize_integer_parameter(
                    params[:entity_template_id]
                  ),

                version:
                  normalize_integer_parameter(
                    params[:version]
                  )
              }

          end


          # ============================================================
          # SEARCH
          # ============================================================

          def build_search_scope

            query =
              @filters[:q].presence || "*"


            where = {}


            where[:status] =
              @filters[:status] if
              @filters[:status].present?


            where[:entity_template_id] =
              @filters[:entity_template_id] if
              @filters[:entity_template_id].present?


            where[:version] =
              @filters[:version] if
              @filters[:version].present?


            VERSION_MODEL.search(
              query,
              where: where,
              order: search_order,
              page: @page,
              per_page: @per_page,
              load: true
            )

          end


          def execute_search(search_scope)

            search_scope

          rescue Searchkick::Error => e

            Rails.logger.error(
              "[EntityTemplateVersion Searchkick] #{e.class}: #{e.message}"
            )

            fallback_index_query

          rescue StandardError => e

            Rails.logger.error(
              "[EntityTemplateVersion Search] #{e.class}: #{e.message}"
            )

            fallback_index_query

          end


          # ============================================================
          # FALLBACK SEARCH
          # ============================================================

          def fallback_index_query

            scope =
              VERSION_MODEL
                .includes(:entity_template)


            scope =
              scope.where(
                status: @filters[:status]
              ) if @filters[:status].present?


            scope =
              scope.where(
                entity_template_id:
                  @filters[:entity_template_id]
              ) if @filters[:entity_template_id].present?


            scope =
              scope.where(
                version: @filters[:version]
              ) if @filters[:version].present?


            if @filters[:q].present?

              query =
                "%#{ActiveRecord::Base.sanitize_sql_like(
                  @filters[:q]
                )}%"


              scope =
                scope.where(
                  <<~SQL.squish,
                    CAST(
                      ecosystems_load_sources_entity_template_versions.version
                      AS TEXT
                    ) ILIKE :query

                    OR
                    ecosystems_load_sources_entity_template_versions.status
                    ILIKE :query

                    OR
                    CAST(
                      ecosystems_load_sources_entity_template_versions.definition
                      AS TEXT
                    ) ILIKE :query

                    OR EXISTS (
                      SELECT 1
                      FROM ecosystems_load_sources_entity_templates
                      WHERE ecosystems_load_sources_entity_templates.id =
                        ecosystems_load_sources_entity_template_versions.entity_template_id
                      AND (
                        ecosystems_load_sources_entity_templates.name ILIKE :query
                        OR ecosystems_load_sources_entity_templates.title ILIKE :query
                        OR ecosystems_load_sources_entity_templates.slug ILIKE :query
                      )
                    )
                  SQL
                  query: query
                )

            end


            scope =
              scope.order(
                "#{safe_sort_column} #{safe_sort_direction}"
              )


            scope
              .page(@page)
              .per(@per_page)

          end


          # ============================================================
          # SORT
          # ============================================================

          def search_order

            {
              safe_sort_column =>
                safe_sort_direction
            }

          end


          def safe_sort_column

            requested =
              params[:sort].to_s


            return DEFAULT_SORT unless
              SORT_COLUMNS.include?(requested)


            requested

          end


          def safe_sort_direction

            requested =
              params[:direction].to_s.downcase


            return DEFAULT_DIRECTION unless
              %w[asc desc].include?(requested)


            requested

          end


          # ============================================================
          # PAGINATION
          # ============================================================

          def prepare_index_pagination

            @page =
              normalize_positive_integer(
                params[:page],
                1
              )


            @per_page =
              normalize_per_page(
                params[:per_page]
              )

          end


          # ============================================================
          # STATISTICS
          # ============================================================

          def prepare_index_statistics

            @filtered_count =
              if @entity_template_versions.respond_to?(:total_count)

                @entity_template_versions.total_count

              elsif @entity_template_versions.respond_to?(:total_entries)

                @entity_template_versions.total_entries

              else

                @entity_template_versions.size

              end


            @filtered_count =
              @filtered_count.to_i


            @total_versions_count =
              VERSION_MODEL.count


            @published_versions_count =
              VERSION_MODEL.where(
                status: "published"
              ).count


            @draft_versions_count =
              VERSION_MODEL.where(
                status: "draft"
              ).count


            @archived_versions_count =
              VERSION_MODEL.where(
                status: "archived"
              ).count


            @search_result_count =
              @filtered_count


            @showing_from =
              @filtered_count.zero? ?
                0 :
                ((@page - 1) * @per_page) + 1


            @showing_to =
              @filtered_count.zero? ?
                0 :
                [
                  @page * @per_page,
                  @filtered_count
                ].min


            @total_pages =
              [
                (
                  @filtered_count.to_f /
                    @per_page
                ).ceil,
                1
              ].max


            @has_results =
              @filtered_count.positive?


            @is_empty_page =
              @has_results &&
                @entity_template_versions.respond_to?(:empty?) &&
                @entity_template_versions.empty?

          end


          # ============================================================
          # METADATA
          # ============================================================

          def prepare_index_metadata

            @search_query =
              @filters[:q]

            @search_status =
              @filters[:status]

            @search_sort =
              safe_sort_column

            @search_direction =
              safe_sort_direction

            @available_statuses =
              STATUS_VALUES

            @available_sort_columns =
              SORT_COLUMNS

            @available_per_page_values =
              [
                25,
                50,
                100,
                200
              ]

            @search_applied =
              @search_query.present? ||
                @search_status.present? ||
                @filters[:entity_template_id].present? ||
                @filters[:version].present?

            @search_message =
              build_search_message

          end


          def build_search_message

            return nil unless @search_applied


            if @search_result_count.zero?

              if @search_query.present?

                "No entity template versions matched “#{@search_query}”."

              else

                "No entity template versions matched the selected filters."

              end

            elsif @search_query.present?

              "Found #{@search_result_count} entity template #{'version'.pluralize(@search_result_count)} matching “#{@search_query}”."

            else

              "Showing #{@search_result_count} entity template #{'version'.pluralize(@search_result_count)} matching the selected filters."

            end

          end


          # ============================================================
          # RENDER INDEX
          # ============================================================

          def render_index

            content =
              render_to_string(
                template:
                  "admin/ecosystems/load_sources/entity_templates/entity_template_versions/index",
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
          # SET VERSION
          # ============================================================

          def set_entity_template_version

            @entity_template_version =
              VERSION_MODEL.find(
                params[:id]
              )

          end


          # ============================================================
          # SET TEMPLATE
          # ============================================================

          def set_entity_template

            @entity_template =
              if @entity_template_version.present?

                @entity_template_version.entity_template

              else

                find_entity_template_for_collection_action

              end

          end


          def find_entity_template_for_collection_action

            return nil if
              params[:entity_template_id].blank?


            ENTITY_TEMPLATE_MODEL.find_by(
              id: params[:entity_template_id]
            )

          end


          # ============================================================
          # COMPARISON
          # ============================================================

          def find_comparison_version(id)

            return nil if id.blank?


            @entity_template
              .entity_template_versions
              .find_by(
                id: id
              )

          end


          def previous_version_for(version)

            return nil unless version.present?


            versions =
              @versions ||
                @entity_template
                  .entity_template_versions
                  .latest_first
                  .to_a


            current_index =
              versions.index do |candidate|

                candidate.id ==
                  version.id

              end


            return nil unless current_index


            versions[
              current_index + 1
            ]

          end


          # ============================================================
          # DEFINITION CHANGES
          # ============================================================

          def build_definition_changes(
            left_definition,
            right_definition
          )

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
              )
                .map(&:to_s)
                .uniq
                .sort


            keys.each_with_object([]) do |key, changes|

              next if key == "fields"


              left_exists =
                left.key?(key) ||
                  left.key?(key.to_sym)


              right_exists =
                right.key?(key) ||
                  right.key?(key.to_sym)


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


              if !left_exists && right_exists

                changes << {
                  key: key,
                  type: "added",
                  left: nil,
                  right: right_value
                }

              elsif left_exists && !right_exists

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


          def fetch_hash_value(hash, key)

            return nil unless hash.is_a?(Hash)


            return hash[key] if hash.key?(key)


            return hash[key.to_sym] if
              hash.key?(key.to_sym)


            nil

          end


          # ============================================================
          # COMPARISON NORMALIZATION
          # ============================================================

          def normalize_comparison_changes(changes)

            if changes.is_a?(Hash)

              changes.map do |attribute, change|

                change_hash =
                  change.is_a?(Hash) ?
                    change :
                    {}


                from_value =
                  change_hash[:from] ||
                    change_hash["from"]


                to_value =
                  change_hash[:to] ||
                    change_hash["to"]


                {
                  key: attribute.to_s,
                  from: from_value,
                  to: to_value,
                  from_text: format_comparison_value(from_value),
                  to_text: format_comparison_value(to_value)
                }

              end

            elsif changes.is_a?(Array)

              changes.map do |change|

                change_hash =
                  change.is_a?(Hash) ?
                    change :
                    {}


                from_value =
                  change_hash[:from] ||
                    change_hash["from"] ||
                    change_hash[:left] ||
                    change_hash["left"]


                to_value =
                  change_hash[:to] ||
                    change_hash["to"] ||
                    change_hash[:right] ||
                    change_hash["right"]


                {
                  key:
                    (
                      change_hash[:key] ||
                        change_hash["key"] ||
                        change_hash[:name] ||
                        change_hash["name"]
                    ).to_s,

                  from: from_value,
                  to: to_value,
                  from_text: format_comparison_value(from_value),
                  to_text: format_comparison_value(to_value)
                }

              end

            else

              []

            end

          end


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
          # STATUS
          # ============================================================

          def normalize_status_filter(value)

            value =
              value.to_s.strip.downcase


            return nil if value.blank?


            return value if
              STATUS_VALUES.include?(value)


            nil

          end


          # ============================================================
          # INTEGER
          # ============================================================

          def normalize_integer_parameter(value)

            return nil if value.blank?


            integer =
              Integer(
                value,
                exception: false
              )


            return nil unless integer


            return nil if integer.negative?


            integer

          end


          def normalize_positive_integer(
            value,
            default
          )

            integer =
              Integer(
                value,
                exception: false
              )


            return default unless integer


            return default if integer < 1


            integer

          end


          # ============================================================
          # PER PAGE
          # ============================================================

          def normalize_per_page(value)

            requested =
              Integer(
                value,
                exception: false
              )


            requested ||=
              DEFAULT_PER_PAGE


            requested =
              DEFAULT_PER_PAGE if requested < 1


            [
              requested,
              MAX_PER_PAGE
            ].min

          end


          # ============================================================
          # DEFINITION PARSING
          # ============================================================

          def parse_definition_parameter

            raw =
              params.dig(
                :ecosystems_load_sources_entity_templates_entity_template_version,
                :definition
              )


            # ----------------------------------------------------------
            # Empty JSON is allowed and becomes an empty structure.
            # ----------------------------------------------------------

            if raw.is_a?(String)

              stripped =
                raw.strip


              return {
                value: {
                  "fields" => []
                }
              } if stripped.blank?


              parsed =
                JSON.parse(
                  stripped
                )


              # --------------------------------------------------------
              # The builder expects an object at the root.
              #
              # Prevent arrays/scalars from silently becoming an
              # invalid template definition.
              # --------------------------------------------------------

              unless parsed.is_a?(Hash)

                return {
                  value: parsed,
                  error:
                    "must contain a JSON object at the root."
                }

              end


              return {
                value:
                  parsed.deep_stringify_keys
              }

            end


            if raw.respond_to?(:to_h)

              return {
                value:
                  raw.to_h.deep_stringify_keys
              }

            end


            {
              value:
                raw.presence || {
                  "fields" => []
                }
            }

          rescue JSON::ParserError => e

            {
              value: {},
              error:
                "contains invalid JSON: #{e.message}"
            }

          end


          # ============================================================
          # NEXT VERSION
          # ============================================================

          def next_version_number

            @entity_template
              .entity_template_versions
              .maximum(:version)
              .to_i + 1

          end


          # ============================================================
          # ENTITY TEMPLATES
          # ============================================================

          def load_entity_templates

            @entity_templates =
              ENTITY_TEMPLATE_MODEL
                .order(:name)

          end

        end

      end
    end
  end
end