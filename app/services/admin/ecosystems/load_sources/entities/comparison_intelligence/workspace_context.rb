
# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        class ComparisonIntelligence
          class WorkspaceContext
            DEFAULT_PER_PAGE = 25
            MAX_PER_PAGE = 100

            attr_reader(
              :entity_id,
              :from_version_id,
              :to_version_id,
              :query,
              :types,
              :risk_levels,
              :reviewed,
              :page,
              :per_page,
              :sort,
              :direction,
              :actor,
              :options
            )

            def initialize(params:, actor: nil, options: {})
              input = normalize_params(params)

              @entity_id = safe_identifier(input["entity_id"])
              @from_version_id = safe_identifier(
                input["from_version_id"] || input["old_version_id"]
              )
              @to_version_id = safe_identifier(
                input["to_version_id"] || input["new_version_id"]
              )

              @query = input["q"].to_s.strip.first(250)
              @types = normalize_list(input["types"] || input["type"])
              @risk_levels = normalize_list(input["risk_levels"] || input["risk"])
              @reviewed = normalize_reviewed(input["reviewed"])

              @page = positive_integer(input["page"], default: 1)
              @per_page = positive_integer(
                input["per_page"],
                default: DEFAULT_PER_PAGE,
                maximum: MAX_PER_PAGE
              )

              @sort = normalize_sort(input["sort"])
              @direction = input["direction"].to_s.downcase == "asc" ? "asc" : "desc"

              @actor = actor
              @options = options.to_h.deep_stringify_keys.freeze

              freeze
            end

            def filtered?
              query.present? ||
                types.any? ||
                risk_levels.any? ||
                !reviewed.nil?
            end

            def revision_pair?
              from_version_id.present? && to_version_id.present?
            end

            def pagination_offset
              (page - 1) * per_page
            end

            def cache_attributes
              {
                entity_id: entity_id,
                from_version_id: from_version_id,
                to_version_id: to_version_id,
                query: query,
                types: types,
                risk_levels: risk_levels,
                reviewed: reviewed,
                page: page,
                per_page: per_page,
                sort: sort,
                direction: direction
              }
            end

            private

            def normalize_params(params)
              value =
                if params.respond_to?(:to_unsafe_h)
                  params.to_unsafe_h
                elsif params.respond_to?(:to_h)
                  params.to_h
                else
                  {}
                end

              value.deep_stringify_keys
            end

            def safe_identifier(value)
              return nil if value.blank?

              text = value.to_s.strip
              return nil unless text.match?(/\A[a-zA-Z0-9_-]{1,100}\z/)

              text
            end

            def normalize_list(value)
              values =
                case value
                when Array then value
                when String then value.split(",")
                else []
                end

              values
                .map { |item| item.to_s.strip.downcase }
                .reject(&:blank?)
                .uniq
                .first(20)
            end

            def normalize_reviewed(value)
              return nil if value.nil? || value.to_s == "all" || value.to_s.blank?

              ActiveModel::Type::Boolean.new.cast(value)
            end


            def positive_integer(value, default:, maximum: nil)
              number =
                if value.is_a?(Integer)
                  value
                elsif value.to_s.match?(/\A\d+\z/)
                  value.to_i
                else
                  return default
                end

              number = 1 if number < 1
              maximum ? [number, maximum].min : number
            end

            def normalize_sort(value)
              allowed = %w[severity magnitude path type reviewed]
              candidate = value.to_s.downcase
              allowed.include?(candidate) ? candidate : "severity"
            end
          end
        end
      end
    end
  end
end