
# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module ResearchWorkspaces
          # Compatibility wrapper for existing callers.
          #
          # DashboardQuery remains responsible for filtering, pagination,
          # and dashboard counts. This class intentionally does not reference
          # DashboardQuery constants while the file is being loaded.
          class DashboardMetrics
            STATUSES = %w[active completed archived].freeze

            def initialize(scope)
              unless scope.respond_to?(:where) &&
                scope.respond_to?(:klass)
                raise ArgumentError,
                      "Expected an Active Record relation"
              end

              @scope = scope
            end

            def counts
              dashboard_query.call.counts
            end

            def filtered(status: nil, query: nil)
              dashboard_query(
                status: status,
                q: query,
                per_page: DashboardQuery::MAX_PER_PAGE
              ).call.workspaces
            end

            private

            attr_reader :scope

            def dashboard_query(params = {})
              query_class = Admin::Ecosystems::LoadSources::Entities::
                  ResearchWorkspaces::DashboardQuery

              query_class.new(scope: scope, params: params)
            end
          end
        end
      end
    end
  end
end