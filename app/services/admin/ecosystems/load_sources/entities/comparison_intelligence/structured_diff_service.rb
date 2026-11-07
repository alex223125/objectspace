
# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        class ComparisonIntelligence
          class StructuredDiffService
            def initialize(normalizer: CanonicalValueNormalizer.new)
              @normalizer = normalizer
            end

            def call(before:, after:, path: "")
              left = normalize(before)
              right = normalize(after)

              return [] if left == right

              if left.is_a?(Hash) && right.is_a?(Hash)
                diff_hashes(left, right, path)
              elsif left.is_a?(Array) && right.is_a?(Array)
                diff_arrays(left, right, path)
              else
                [change(path, left, right)]
              end
            end

            private

            attr_reader :normalizer

            def normalize(value)
              normalizer.call(value)
            end

            def diff_hashes(before, after, path)
              (before.keys | after.keys).sort.flat_map do |key|
                child_path = join_path(path, key)

                if !before.key?(key)
                  [change(child_path, nil, after[key], "added")]
                elsif !after.key?(key)
                  [change(child_path, before[key], nil, "removed")]
                else
                  call(
                    before: before[key],
                    after: after[key],
                    path: child_path
                  )
                end
              end
            end

            def diff_arrays(before, after, path)
              before_map = indexed_items(before)
              after_map = indexed_items(after)

              if before_map && after_map
                (before_map.keys | after_map.keys).sort_by(&:to_s).flat_map do |key|
                  child_path = "#{path}[#{key}]"

                  if !before_map.key?(key)
                    [change(child_path, nil, after_map[key], "added")]
                  elsif !after_map.key?(key)
                    [change(child_path, before_map[key], nil, "removed")]
                  else
                    call(
                      before: before_map[key],
                      after: after_map[key],
                      path: child_path
                    )
                  end
                end
              else
                positional_array_diff(before, after, path)
              end
            end

            def indexed_items(items)
              return nil unless items.all? { |item| item.is_a?(Hash) }

              keys = items.map do |item|
                item["id"] || item[:id] ||
                  item["key"] || item[:key] ||
                  item["slug"] || item[:slug]
              end

              return nil if keys.any?(&:blank?) || keys.uniq.length != keys.length

              items.each_with_object({}) do |item, result|
                key = item["id"] || item[:id] ||
                  item["key"] || item[:key] ||
                  item["slug"] || item[:slug]

                result[key.to_s] = item
              end
            end

            def positional_array_diff(before, after, path)
              maximum = [before.length, after.length].max

              (0...maximum).flat_map do |index|
                child_path = "#{path}[#{index}]"

                if index >= before.length
                  [change(child_path, nil, after[index], "added")]
                elsif index >= after.length
                  [change(child_path, before[index], nil, "removed")]
                else
                  call(
                    before: before[index],
                    after: after[index],
                    path: child_path
                  )
                end
              end
            end

            def change(path, before, after, type = "changed")
              {
                path: path.presence || "$",
                type: type,
                before: before,
                after: after
              }
            end

            def join_path(parent, child)
              parent.present? ? "#{parent}.#{child}" : child.to_s
            end
          end
        end
      end
    end
  end
end