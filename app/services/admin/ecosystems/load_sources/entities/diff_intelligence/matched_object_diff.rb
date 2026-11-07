# frozen_string_literal: true

module Ecosystems
  module LoadSources
    module Entity
      module DiffIntelligence
        class MatchedObjectDiff
          Result = Struct.new(
            :changes,
            keyword_init: true
          ) do
            def changed?
              changes.any?
            end
          end

          def self.call(old_object:, new_object:)
            new(
              old_object: old_object,
              new_object: new_object
            ).call
          end

          def initialize(old_object:, new_object:)
            @old_object = old_object
            @new_object = new_object
          end

          def call
            changes = []

            compare_values(
              old_value: @old_object,
              new_value: @new_object,
              path: [],
              changes: changes
            )

            Result.new(changes: changes)
          end

          private

          attr_reader :old_object, :new_object

          def compare_values(old_value:, new_value:, path:, changes:)
            if old_value.is_a?(Hash) && new_value.is_a?(Hash)
              compare_hashes(
                old_value: old_value,
                new_value: new_value,
                path: path,
                changes: changes
              )

              return
            end

            if old_value.is_a?(Array) && new_value.is_a?(Array)
              compare_arrays(
                old_value: old_value,
                new_value: new_value,
                path: path,
                changes: changes
              )

              return
            end

            return if values_equal?(old_value, new_value)

            changes << {
              path: path_to_string(path),
              path_parts: path,
              state: :changed,
              old_value: old_value,
              new_value: new_value
            }
          end

          def compare_hashes(old_value:, new_value:, path:, changes:)
            keys =
              (
                old_value.keys.map(&:to_s) +
                  new_value.keys.map(&:to_s)
              ).uniq.sort

            keys.each do |key|
              old_present = key_exists?(old_value, key)
              new_present = key_exists?(new_value, key)

              old_child = fetch_key(old_value, key)
              new_child = fetch_key(new_value, key)

              child_path = path + [key]

              if !old_present && new_present
                changes << {
                  path: path_to_string(child_path),
                  path_parts: child_path,
                  state: :added,
                  old_value: nil,
                  new_value: new_child
                }

                next
              end

              if old_present && !new_present
                changes << {
                  path: path_to_string(child_path),
                  path_parts: child_path,
                  state: :removed,
                  old_value: old_child,
                  new_value: nil
                }

                next
              end

              compare_values(
                old_value: old_child,
                new_value: new_child,
                path: child_path,
                changes: changes
              )
            end
          end

          def compare_arrays(old_value:, new_value:, path:, changes:)
            max_size = [old_value.length, new_value.length].max

            max_size.times do |index|
              old_present = index < old_value.length
              new_present = index < new_value.length

              child_path = path + [index]

              if !old_present
                changes << {
                  path: path_to_string(child_path),
                  path_parts: child_path,
                  state: :added,
                  old_value: nil,
                  new_value: new_value[index]
                }

                next
              end

              if !new_present
                changes << {
                  path: path_to_string(child_path),
                  path_parts: child_path,
                  state: :removed,
                  old_value: old_value[index],
                  new_value: nil
                }

                next
              end

              compare_values(
                old_value: old_value[index],
                new_value: new_value[index],
                path: child_path,
                changes: changes
              )
            end
          end

          def key_exists?(hash, key)
            hash.key?(key) || hash.key?(key.to_sym)
          end

          def fetch_key(hash, key)
            return hash[key] if hash.key?(key)
            return hash[key.to_sym] if hash.key?(key.to_sym)

            nil
          end

          def values_equal?(old_value, new_value)
            normalize(old_value) == normalize(new_value)
          end

          def normalize(value)
            case value
            when Hash
              value
                .sort_by { |key, _| key.to_s }
                .to_h do |key, nested_value|
                [
                  key.to_s,
                  normalize(nested_value)
                ]
              end
            when Array
              value.map { |item| normalize(item) }
            else
              value
            end
          end

          def path_to_string(path)
            return "" if path.empty?

            path.map do |part|
              part.is_a?(Integer) ? "[#{part}]" : part.to_s
            end.join(".").gsub(".[", "[")
          end
        end
      end
    end
  end
end