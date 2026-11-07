
# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        class ComparisonIntelligence
          class TextDiffService
            MAX_LINES = 2_000

            def call(before:, after:)
              old_lines = lines(before)
              new_lines = lines(after)

              return [] if old_lines == new_lines

              operations = longest_common_subsequence(old_lines, new_lines)

              operations.map do |operation, value|
                {
                  operation: operation,
                  text: value
                }
              end
            end

            private

            def lines(value)
              value.to_s.lines(chomp: true).first(MAX_LINES)
            end

            def longest_common_subsequence(old_lines, new_lines)
              old_count = old_lines.length
              new_count = new_lines.length

              # Bound memory use for very large fields.
              if old_count * new_count > 250_000
                return fallback_diff(old_lines, new_lines)
              end

              matrix = Array.new(old_count + 1) do
                Array.new(new_count + 1, 0)
              end

              (old_count - 1).downto(0) do |i|
                (new_count - 1).downto(0) do |j|
                  matrix[i][j] =
                    if old_lines[i] == new_lines[j]
                      matrix[i + 1][j + 1] + 1
                    else
                      [matrix[i + 1][j], matrix[i][j + 1]].max
                    end
                end
              end

              operations = []
              i = 0
              j = 0

              while i < old_count && j < new_count
                if old_lines[i] == new_lines[j]
                  operations << [:unchanged, old_lines[i]]
                  i += 1
                  j += 1
                elsif matrix[i + 1][j] >= matrix[i][j + 1]
                  operations << [:removed, old_lines[i]]
                  i += 1
                else
                  operations << [:added, new_lines[j]]
                  j += 1
                end
              end

              while i < old_count
                operations << [:removed, old_lines[i]]
                i += 1
              end

              while j < new_count
                operations << [:added, new_lines[j]]
                j += 1
              end

              operations
            end

            def fallback_diff(old_lines, new_lines)
              common_prefix = 0

              while common_prefix < old_lines.length &&
                common_prefix < new_lines.length &&
                old_lines[common_prefix] == new_lines[common_prefix]
                common_prefix += 1
              end

              common_suffix = 0

              while common_suffix < old_lines.length - common_prefix &&
                common_suffix < new_lines.length - common_prefix &&
                old_lines[-1 - common_suffix] == new_lines[-1 - common_suffix]
                common_suffix += 1
              end

              result = old_lines.first(common_prefix).map { |line| [:unchanged, line] }

              old_middle = old_lines[common_prefix, old_lines.length - common_prefix - common_suffix] || []
              new_middle = new_lines[common_prefix, new_lines.length - common_prefix - common_suffix] || []

              result.concat(old_middle.map { |line| [:removed, line] })
              result.concat(new_middle.map { |line| [:added, line] })

              if common_suffix.positive?
                result.concat(old_lines.last(common_suffix).map { |line| [:unchanged, line] })
              end

              result
            end
          end
        end
      end
    end
  end
end