# app/controllers/admin/ecosystems/load_sources/entity_templates/entity_template_versions_controller.rb

module Admin
  module Ecosystems
    module LoadSources
      module EntityTemplates

        class EntityTemplateVersionsController < ::AdminController

          # ============================================================
          # CONSTANTS
          # ============================================================

          VERSION_MODEL =
            ::Ecosystems::LoadSources::EntityTemplates::EntityTemplateVersion

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
                          :clone
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
                          :clone
                        ]


          # ============================================================
          # INDEX
          # ============================================================
          #
          # Searchkick-powered version registry.
          #
          # Supported parameters:
          #
          # q
          # status
          # entity_template_id
          # version
          # sort
          # direction
          # page
          # per_page
          #
          # Example:
          #
          # ?q=scientific
          #
          # ?q=scientific&status=published
          #
          # ?sort=version&direction=desc
          #
          # ?page=2&per_page=100
          #
          # ============================================================

          def index

            # IMPORTANT:
            #
            # Pagination MUST be prepared before:
            #
            # 1. build_search_scope
            # 2. prepare_index_statistics
            #
            # Both methods use @page and @per_page.

            prepare_index_filters

            prepare_index_pagination

            search_scope =
              build_search_scope

            @entity_template_versions =
              execute_search(
                search_scope
              )

            prepare_index_statistics

            prepare_index_metadata

            render_index

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
                .order(
                  version: :desc
                )

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
                notice:
                  "Entity template version was successfully created."
              )

            else

              render(
                :new,
                status: :unprocessable_entity
              )

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
                notice:
                  "Entity template version was successfully updated."
              )

            else

              render(
                :edit,
                status: :unprocessable_entity
              )

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
              notice:
                "Entity template version was successfully deleted."
            )

          end


          # ============================================================
          # COMPARE
          # ============================================================

          def compare

            @versions =
              @entity_template
                .entity_template_versions
                .order(
                  version: :desc
                )


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
              # DEFINITION CHANGES
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
                    field.is_a?(Hash) ?
                      field :
                      {}


                  changes =
                    field_hash[:changes] ||
                      field_hash["changes"] ||
                      {}


                  normalized_changes =
                    normalize_comparison_changes(
                      changes
                    )


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
                      normalized_changes
                  }

                end

            else

              # --------------------------------------------------------
              # NO COMPARISON AVAILABLE
              # --------------------------------------------------------

              @left_definition = {}

              @right_definition = {}

              @field_comparisons = []

              @field_changes = []

              @definition_changes = []

              @comparison_summary =
                {
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
                "Entity template version #{source_version.version} was successfully cloned as draft version #{cloned_version.version}."
            )


          rescue ActiveRecord::RecordInvalid => e

            Rails.logger.error(
              "[EntityTemplateVersion Clone] #{e.class}: #{e.message}"
            )


            redirect_to(
              admin_ecosystems_load_sources_entity_templates_entity_template_version_path(
                source_version
              ),
              alert:
                "Unable to clone entity template version: #{e.record.errors.full_messages.to_sentence}"
            )

          end


          private


          # ============================================================
          # INDEX — FILTERS
          # ============================================================

          def prepare_index_filters

            @filters =
              {
                q:
                  params[:q].to_s.strip,

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
          # INDEX — SEARCH SCOPE
          # ============================================================

          def build_search_scope

            query =
              @filters[:q].presence || "*"


            where =
              {}


            # ----------------------------------------------------------
            # STATUS
            # ----------------------------------------------------------

            if @filters[:status].present?

              where[:status] =
                @filters[:status]

            end


            # ----------------------------------------------------------
            # ENTITY TEMPLATE
            # ----------------------------------------------------------

            if @filters[:entity_template_id].present?

              where[:entity_template_id] =
                @filters[:entity_template_id]

            end


            # ----------------------------------------------------------
            # VERSION
            # ----------------------------------------------------------

            if @filters[:version].present?

              where[:version] =
                @filters[:version]

            end


            VERSION_MODEL.search(
              query,

              where: where,

              order:
                search_order,

              page:
                @page,

              per_page:
                @per_page,

              load: true
            )

          end


          # ============================================================
          # INDEX — EXECUTE SEARCH
          # ============================================================

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
          # INDEX — FALLBACK
          # ============================================================
          #
          # This protects the admin interface if Elasticsearch/OpenSearch
          # is temporarily unavailable.
          #
          # It is deliberately SQL-based and only used as a fallback.
          #
          # ============================================================

          def fallback_index_query

            scope =
              VERSION_MODEL
                .includes(:entity_template)


            # ----------------------------------------------------------
            # STATUS
            # ----------------------------------------------------------

            if @filters[:status].present?

              scope =
                scope.where(
                  status: @filters[:status]
                )

            end


            # ----------------------------------------------------------
            # ENTITY TEMPLATE
            # ----------------------------------------------------------

            if @filters[:entity_template_id].present?

              scope =
                scope.where(
                  entity_template_id:
                    @filters[:entity_template_id]
                )

            end


            # ----------------------------------------------------------
            # VERSION
            # ----------------------------------------------------------

            if @filters[:version].present?

              scope =
                scope.where(
                  version:
                    @filters[:version]
                )

            end


            # ----------------------------------------------------------
            # TEXT SEARCH
            # ----------------------------------------------------------

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
                  SQL
                  query: query
                )

            end


            # ----------------------------------------------------------
            # SORT
            # ----------------------------------------------------------

            scope =
              scope.order(
                "#{safe_sort_column} #{safe_sort_direction}"
              )


            # ----------------------------------------------------------
            # PAGINATION
            # ----------------------------------------------------------

            scope =
              scope
                .page(@page)
                .per(@per_page)


            scope

          end


          # ============================================================
          # INDEX — SORT
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
              %w[
                asc
                desc
              ].include?(requested)


            requested

          end


          # ============================================================
          # INDEX — PAGINATION
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
          # INDEX — STATISTICS
          # ============================================================

          def prepare_index_statistics

            # ----------------------------------------------------------
            # SEARCH RESULT COUNT
            # ----------------------------------------------------------
            #
            # Searchkick:
            #   total_count
            #
            # Kaminari/Pagy-style fallback:
            #   total_entries
            #
            # Plain collection:
            #   size
            #
            # ----------------------------------------------------------

            @filtered_count =
              if @entity_template_versions.respond_to?(:total_count)

                @entity_template_versions.total_count

              elsif @entity_template_versions.respond_to?(:total_entries)

                @entity_template_versions.total_entries

              elsif @entity_template_versions.respond_to?(:count)

                @entity_template_versions.count

              else

                @entity_template_versions.size

              end


            @filtered_count =
              @filtered_count.to_i


            # ----------------------------------------------------------
            # GLOBAL COUNTS
            # ----------------------------------------------------------
            #
            # These intentionally represent the entire registry rather
            # than only the current filtered result.
            #
            # ----------------------------------------------------------

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


            # ----------------------------------------------------------
            # SEARCH RESULT COUNT
            # ----------------------------------------------------------

            @search_result_count =
              @filtered_count


            # ----------------------------------------------------------
            # SHOWING RANGE
            # ----------------------------------------------------------
            #
            # @page and @per_page are guaranteed to be initialized
            # because prepare_index_pagination now runs BEFORE this
            # method.
            #
            # ----------------------------------------------------------

            @showing_from =
              if @filtered_count.zero?

                0

              else

                ((@page - 1) * @per_page) + 1

              end


            @showing_to =
              if @filtered_count.zero?

                0

              else

                [
                  @page * @per_page,
                  @filtered_count
                ].min

              end


            # ----------------------------------------------------------
            # TOTAL PAGES
            # ----------------------------------------------------------

            @total_pages =
              if @filtered_count.zero?

                1

              else

                (
                  @filtered_count.to_f /
                    @per_page
                ).ceil

              end


            @total_pages =
              1 if @total_pages < 1


            # ----------------------------------------------------------
            # CURRENT PAGE SAFETY
            # ----------------------------------------------------------
            #
            # If a user requests a page beyond the final page, we keep
            # the requested page here rather than silently changing the
            # Searchkick query after it has already executed.
            #
            # The view can safely detect an empty page.
            #
            # ----------------------------------------------------------

            @has_results =
              @filtered_count.positive?


            @is_empty_page =
              @has_results &&
                @entity_template_versions.respond_to?(:empty?) &&
                @entity_template_versions.empty?

          end


          # ============================================================
          # INDEX — METADATA
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


          # ============================================================
          # INDEX — SEARCH MESSAGE
          # ============================================================

          def build_search_message

            return nil unless @search_applied


            if @search_result_count.to_i.zero?

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
          # INDEX — RENDER
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
          # ENTITY TEMPLATE VERSION
          # ============================================================

          def set_entity_template_version

            @entity_template_version =
              VERSION_MODEL.find(
                params[:id]
              )

          end


          # ============================================================
          # ENTITY TEMPLATE
          # ============================================================

          def set_entity_template

            @entity_template =
              if @entity_template_version.present?

                @entity_template_version.entity_template

              else

                find_entity_template_for_collection_action

              end


            return if @entity_template.present?

          end


          # ============================================================
          # COLLECTION ENTITY TEMPLATE
          # ============================================================

          def find_entity_template_for_collection_action

            return nil if
              params[:entity_template_id].blank?


            ::Ecosystems::LoadSources::EntityTemplates::EntityTemplate.find_by(
              id:
                params[:entity_template_id]
            )

          end


          # ============================================================
          # FIND COMPARISON VERSION
          # ============================================================

          def find_comparison_version(id)

            return nil if id.blank?


            @entity_template
              .entity_template_versions
              .find_by(
                id: id
              )

          end


          # ============================================================
          # PREVIOUS VERSION
          # ============================================================

          def previous_version_for(version)

            return nil unless version.present?


            @versions ||=
              @entity_template
                .entity_template_versions
                .order(
                  version: :desc
                )


            versions =
              @versions.to_a


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


            if hash.key?(key)

              hash[key]

            elsif hash.key?(key.to_sym)

              hash[key.to_sym]

            end

          end


          # ============================================================
          # COMPARISON CHANGES
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
                  key:
                    attribute.to_s,

                  from:
                    from_value,

                  to:
                    to_value,

                  from_text:
                    format_comparison_value(
                      from_value
                    ),

                  to_text:
                    format_comparison_value(
                      to_value
                    )
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

                  from:
                    from_value,

                  to:
                    to_value,

                  from_text:
                    format_comparison_value(
                      from_value
                    ),

                  to_text:
                    format_comparison_value(
                      to_value
                    )
                }

              end

            else

              []

            end

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

              value.presence ||
                "empty"

            when Array, Hash

              JSON.pretty_generate(
                value
              )

            else

              value.to_s

            end

          rescue StandardError

            value.to_s

          end


          # ============================================================
          # STATUS NORMALIZATION
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
          # INTEGER PARAMETER
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


          # ============================================================
          # POSITIVE INTEGER
          # ============================================================

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
              DEFAULT_PER_PAGE if
              requested < 1


            [
              requested,
              MAX_PER_PAGE
            ].min

          end


          # ============================================================
          # STRONG PARAMETERS
          # ============================================================

          def entity_template_version_params

            params
              .require(
                :entity_template_version
              )
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
                .order(
                  version: :desc
                )
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
