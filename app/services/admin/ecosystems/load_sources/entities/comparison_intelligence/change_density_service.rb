
# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        class ComparisonIntelligence
          class ChangeDensityService
            def call(changes:, total_fields: nil)
              items = Array(changes)
              changed_paths = items.map { |item| read(item, :path).to_s }.uniq
              field_count = [total_fields.to_i, changed_paths.length].max

              weighted_magnitude = items.sum do |item|
                [[read(item, :magnitude).to_i, 0].max, 100].min
              end

              distribution = items.group_by do |item|
                read(item, :path).to_s.presence || "Unknown path"
              end.transform_values(&:length)

              {
                changed_fields: changed_paths.length,
                total_fields: field_count,
                density_percentage: field_count.zero? ? 0 :
                                      ((changed_paths.length.to_f / field_count) * 100).round(1),
                weighted_magnitude: weighted_magnitude,
                average_magnitude: items.empty? ? 0 :
                                     (weighted_magnitude.to_f / items.length).round(1),
                path_concentration: concentration(distribution),
                path_distribution: distribution.sort_by { |_path, count| -count }.to_h
              }
            end

            private

            def read(item, key)
              item.respond_to?(:[]) ? (item[key] || item[key.to_s]) : nil
            end

            def concentration(distribution)
              total = distribution.values.sum
              return 0 if total.zero?

              largest_group = distribution.values.max || 0
              ((largest_group.to_f / total) * 100).round(1)
            end
          end
        end
      end
    end
  end
end