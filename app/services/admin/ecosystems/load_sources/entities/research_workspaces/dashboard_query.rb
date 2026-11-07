
# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module ResearchWorkspaces
          class DashboardQuery
            STATUSES = %w[active completed archived].freeze
            DEFAULT_PER_PAGE = 30
            MAX_PER_PAGE = 100
            DEFAULT_PAGE = 1

            Result = Struct.new(
              :workspaces,
              :counts,
              :status,
              :query,
              :page,
              :per_page,
              :total_count,
              :total_pages,
              keyword_init: true
            )

            def initialize(scope:, params: {})
              @scope = scope
              @params = params || {}
            end

            def call
              validate_scope!

              relation = filtered_relation
              total_count = relation.count
              per_page = selected_per_page
              page = selected_page
              total_pages = (total_count.to_f / per_page).ceil

              records = relation
                          .includes(:items)
                          .order(updated_at: :desc, id: :desc)
                          .limit(per_page)
                          .offset((page - 1) * per_page)

              Result.new(
                workspaces: records,
                counts: dashboard_counts,
                status: selected_status,
                query: search_query,
                page: page,
                per_page: per_page,
                total_count: total_count,
                total_pages: total_pages
              )
            end

            private

            attr_reader :scope, :params

            def validate_scope!
              unless scope.respond_to?(:klass) &&
                scope.respond_to?(:where)
                raise ArgumentError,
                      "Expected an Active Record relation"
              end

              required_columns = %w[status title updated_at id]

              missing = required_columns.reject do |column|
                scope.klass.column_names.include?(column)
              end

              return if missing.empty?

              raise ArgumentError,
                    "Research workspace schema is missing: " \
                      "#{missing.join(', ')}"
            end

            # Counts describe the full authorized scope, independently
            # of search, status filtering, and pagination.
            def dashboard_counts
              {
                active: scope.where(status: "active").count,
                completed: scope.where(status: "completed").count,
                archived: scope.where(status: "archived").count,
                collections: collection_count
              }
            end

            # Collection membership is optional. The association currently
            # references a missing model constant, so do not inspect or
            # resolve collection associations here.
            #
            # Replace this fallback when the actual collection schema
            # and its ownership/membership associations are confirmed.
            def collection_count
              0
            end

            def filtered_relation
              relation = scope

              status = selected_status
              relation = relation.where(status: status) if status.present?

              query = search_query
              relation = apply_search(relation, query) if query.present?

              relation
            end

            def apply_search(relation, query)
              columns = %w[title slug] & scope.klass.column_names
              return relation if columns.empty?

              table = scope.klass.arel_table
              escaped = "%#{scope.klass.sanitize_sql_like(query)}%"

              predicate = columns
                            .map { |column| table[column].matches(escaped) }
                            .reduce { |left, right| left.or(right) }

              relation.where(predicate)
            end

            def selected_status
              candidate = params[:status].to_s.strip
              STATUSES.include?(candidate) ? candidate : nil
            end

            def search_query
              params[:q].to_s.strip.presence
            end

            def selected_page
              positive_integer(params[:page], DEFAULT_PAGE)
            end

            def selected_per_page
              positive_integer(
                params[:per_page],
                DEFAULT_PER_PAGE
              ).clamp(1, MAX_PER_PAGE)
            end

            def positive_integer(value, fallback)
              integer = Integer(value.to_s, 10)
              integer.positive? ? integer : fallback
            rescue ArgumentError, TypeError
              fallback
            end
          end
        end
      end
    end
  end
end