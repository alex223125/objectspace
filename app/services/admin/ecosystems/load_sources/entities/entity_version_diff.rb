# frozen_string_literal: true

module Ecosystems
  module LoadSources
    module Entities

      class EntityVersionDiff

        CHANGE_TYPES = %w[
          added
          removed
          changed
          reordered
          unchanged
        ].freeze

        Result = Struct.new(
          :nodes,
          :summary,
          keyword_init: true
        )

        Node = Struct.new(
          :path,
          :key,
          :kind,
          :change_type,
          :old_value,
          :new_value,
          :children,
          :array_index,
          :old_index,
          :new_index,
          :metadata,
          keyword_init: true
        )

        def self.call(old_version:, new_version:)
          new(
            old_version: old_version,
            new_version: new_version
          ).call
        end

        def initialize(old_version:, new_version:)
          @old_version = old_version
          @new_version = new_version
        end

        def call
          old_snapshot = normalize_snapshot(@old_version.snapshot)
          new_snapshot = normalize_snapshot(@new_version.snapshot)

          nodes = compare_values(
            old_snapshot,
            new_snapshot,
            path: nil,
            key: nil
          )

          Result.new(
            nodes: nodes,
            summary: build_summary(nodes)
          )
        end

        private

        attr_reader :old_version, :new_version

        # ==========================================================
        # VALUE COMPARISON
        # ==========================================================

        def compare_values(old_value, new_value, path:, key:)
          if old_value.nil? && !new_value.nil?
            return [
              node(
                path: path,
                key: key,
                kind: :value,
                change_type: :added,
                old_value: nil,
                new_value: new_value
              )
            ]
          end

          if !old_value.nil? && new_value.nil?
            return [
              node(
                path: path,
                key: key,
                kind: :value,
                change_type: :removed,
                old_value: old_value,
                new_value: nil
              )
            ]
          end

          if hash_like?(old_value) && hash_like?(new_value)
            return compare_hashes(
              old_value,
              new_value,
              path: path
            )
          end

          if array_like?(old_value) && array_like?(new_value)
            return compare_arrays(
              old_value,
              new_value,
              path: path
            )
          end

          if old_value == new_value
            [
              node(
                path: path,
                key: key,
                kind: scalar_kind(old_value),
                change_type: :unchanged,
                old_value: old_value,
                new_value: new_value
              )
            ]
          else
            [
              node(
                path: path,
                key: key,
                kind: scalar_kind(new_value || old_value),
                change_type: :changed,
                old_value: old_value,
                new_value: new_value,
                metadata: {
                  type_changed:
                    value_type(old_value) != value_type(new_value)
                }
              )
            ]
          end
        end

        # ==========================================================
        # HASHES
        # ==========================================================

        def compare_hashes(old_hash, new_hash, path:)
          old_hash = normalize_hash(old_hash)
          new_hash = normalize_hash(new_hash)

          keys =
            (
              old_hash.keys +
                new_hash.keys
            ).uniq.sort_by(&:to_s)

          keys.flat_map do |key|
            child_path =
              append_path(path, key)

            if !old_hash.key?(key)
              [
                node(
                  path: child_path,
                  key: key,
                  kind: :object,
                  change_type: :added,
                  old_value: nil,
                  new_value: new_hash[key]
                )
              ]
            elsif !new_hash.key?(key)
              [
                node(
                  path: child_path,
                  key: key,
                  kind: :object,
                  change_type: :removed,
                  old_value: old_hash[key],
                  new_value: nil
                )
              ]
            else
              compare_values(
                old_hash[key],
                new_hash[key],
                path: child_path,
                key: key
              )
            end
          end
        end

        # ==========================================================
        # ARRAYS
        # ==========================================================

        def compare_arrays(old_array, new_array, path:)
          old_array = Array(old_array)
          new_array = Array(new_array)

          return compare_indexed_arrays(
            old_array,
            new_array,
            path: path
          ) if arrays_are_positional?(old_array, new_array)

          compare_semantic_arrays(
            old_array,
            new_array,
            path: path
          )
        end

        def arrays_are_positional?(old_array, new_array)
          old_array.empty? ||
            new_array.empty? ||
            old_array.any? { |value| scalar_value?(value) } ||
            new_array.any? { |value| scalar_value?(value) }
        end

        # ----------------------------------------------------------
        # POSITIONAL ARRAYS
        # ----------------------------------------------------------

        def compare_indexed_arrays(old_array, new_array, path:)
          max_length =
            [old_array.length, new_array.length].max

          nodes = []

          max_length.times do |index|
            old_present = index < old_array.length
            new_present = index < new_array.length

            child_path =
              append_path(path, index)

            if old_present && new_present
              nodes.concat(
                compare_values(
                  old_array[index],
                  new_array[index],
                  path: child_path,
                  key: index
                )
              )
            elsif new_present
              nodes << node(
                path: child_path,
                key: index,
                kind: :array_item,
                change_type: :added,
                old_value: nil,
                new_value: new_array[index],
                array_index: index,
                new_index: index
              )
            else
              nodes << node(
                path: child_path,
                key: index,
                kind: :array_item,
                change_type: :removed,
                old_value: old_array[index],
                new_value: nil,
                array_index: index,
                old_index: index
              )
            end
          end

          nodes
        end

        # ----------------------------------------------------------
        # SEMANTIC ARRAYS
        # ----------------------------------------------------------

        def compare_semantic_arrays(old_array, new_array, path:)
          old_keys =
            old_array.map { |value| semantic_key(value) }

          new_keys =
            new_array.map { |value| semantic_key(value) }

          old_counts = old_keys.tally
          new_counts = new_keys.tally

          all_keys =
            (
              old_counts.keys +
                new_counts.keys
            ).uniq

          nodes = []

          all_keys.each do |semantic_key|
            old_indexes =
              indexes_for(old_keys, semantic_key)

            new_indexes =
              indexes_for(new_keys, semantic_key)

            common_count =
              [old_indexes.length, new_indexes.length].min

            common_count.times do |position|
              old_index = old_indexes[position]
              new_index = new_indexes[position]

              old_value = old_array[old_index]
              new_value = new_array[new_index]

              if old_value == new_value
                change_type =
                  old_index == new_index ? :unchanged : :reordered

                nodes << node(
                  path:
                    append_path(path, new_index),
                  key: semantic_key,
                  kind: :array_item,
                  change_type: change_type,
                  old_value: old_value,
                  new_value: new_value,
                  array_index: new_index,
                  old_index: old_index,
                  new_index: new_index,
                  metadata: {
                    semantic_key: semantic_key
                  }
                )
              else
                nested =
                  compare_values(
                    old_value,
                    new_value,
                    path: append_path(path, new_index),
                    key: semantic_key
                  )

                nodes.concat(
                  annotate_array_nodes(
                    nested,
                    old_index: old_index,
                    new_index: new_index,
                    semantic_key: semantic_key
                  )
                )
              end
            end

            if old_indexes.length > common_count
              old_indexes.drop(common_count).each do |old_index|
                nodes << node(
                  path:
                    append_path(path, old_index),
                  key: semantic_key,
                  kind: :array_item,
                  change_type: :removed,
                  old_value: old_array[old_index],
                  new_value: nil,
                  array_index: old_index,
                  old_index: old_index,
                  metadata: {
                    semantic_key: semantic_key
                  }
                )
              end
            end

            if new_indexes.length > common_count
              new_indexes.drop(common_count).each do |new_index|
                nodes << node(
                  path:
                    append_path(path, new_index),
                  key: semantic_key,
                  kind: :array_item,
                  change_type: :added,
                  old_value: nil,
                  new_value: new_array[new_index],
                  array_index: new_index,
                  new_index: new_index,
                  metadata: {
                    semantic_key: semantic_key
                  }
                )
              end
            end
          end

          nodes.sort_by do |item|
            [
              item.new_index || item.old_index || 0,
              item.path.to_s
            ]
          end
        end

        def annotate_array_nodes(
          nodes,
          old_index:,
          new_index:,
          semantic_key:
        )
          nodes.map do |item|
            item.old_index ||= old_index
            item.new_index ||= new_index

            item.metadata =
              (item.metadata || {}).merge(
                semantic_key: semantic_key
              )

            item
          end
        end

        # ==========================================================
        # SEMANTIC ARRAY KEYS
        # ==========================================================

        def semantic_key(value)
          return "nil" if value.nil?

          if value.is_a?(Hash)
            normalized =
              normalize_hash(value)

            preferred_keys = %w[
              id
              uuid
              key
              slug
              code
              name
              type
            ]

            preferred_keys.each do |preferred|
              return "#{preferred}:#{normalized[preferred]}" if
                normalized.key?(preferred)
            end

            return Digest::SHA256.hexdigest(
              JSON.generate(
                normalized.sort.to_h
              )
            )
          end

          value.to_s
        end

        def indexes_for(keys, target)
          keys.each_index.select do |index|
            keys[index] == target
          end
        end

        # ==========================================================
        # SUMMARY
        # ==========================================================

        def build_summary(nodes)
          flattened = flatten_nodes(nodes)

          counts =
            CHANGE_TYPES.index_with do |type|
              flattened.count do |item|
                item.change_type.to_s == type
              end
            end

          {
            total: flattened.length,
            changed: counts["changed"],
            added: counts["added"],
            removed: counts["removed"],
            reordered: counts["reordered"],
            unchanged: counts["unchanged"],
            changes:
              counts["changed"] +
                counts["added"] +
                counts["removed"] +
                counts["reordered"]
          }
        end

        def flatten_nodes(nodes)
          nodes.flat_map do |item|
            [
              item,
              *flatten_nodes(item.children || [])
            ]
          end
        end

        # ==========================================================
        # NODE
        # ==========================================================

        def node(
          path:,
          key:,
          kind:,
          change_type:,
          old_value:,
          new_value:,
          array_index: nil,
          old_index: nil,
          new_index: nil,
          metadata: nil
        )
          Node.new(
            path: path.to_s,
            key: key,
            kind: kind.to_s,
            change_type: change_type.to_s,
            old_value: old_value,
            new_value: new_value,
            children: [],
            array_index: array_index,
            old_index: old_index,
            new_index: new_index,
            metadata: metadata || {}
          )
        end

        # ==========================================================
        # NORMALIZATION
        # ==========================================================

        def normalize_snapshot(value)
          case value
          when Hash
            normalize_hash(value)
          when Array
            value.map { |item| normalize_snapshot(item) }
          else
            value
          end
        end

        def normalize_hash(value)
          value.each_with_object({}) do |(key, item), result|
            result[key.to_s] =
              normalize_snapshot(item)
          end
        end

        def hash_like?(value)
          value.is_a?(Hash)
        end

        def array_like?(value)
          value.is_a?(Array)
        end

        def scalar_value?(value)
          !hash_like?(value) && !array_like?(value)
        end

        def scalar_kind(value)
          value_type(value).to_sym
        end

        def value_type(value)
          case value
          when Hash
            "object"
          when Array
            "array"
          when String
            "string"
          when Integer
            "integer"
          when Float
            "float"
          when TrueClass, FalseClass
            "boolean"
          when NilClass
            "null"
          else
            value.class.name.to_s.downcase
          end
        end

        # ==========================================================
        # PATHS
        # ==========================================================

        def append_path(path, key)
          return key.to_s if path.blank?

          if key.is_a?(Integer)
            "#{path}[#{key}]"
          else
            "#{path}.#{key}"
          end
        end


        def self.serialize_node(node)
          {
            path: node.path,
            key: node.key,
            kind: node.kind,
            change_type: node.change_type,
            old_value: node.old_value,
            new_value: node.new_value,
            array_index: node.array_index,
            old_index: node.old_index,
            new_index: node.new_index,
            metadata: node.metadata,
            children:
              Array(node.children).map do |child|
                serialize_node(child)
              end
          }
        end

        def self.serialize(result)
          {
            nodes:
              result.nodes.map do |node|
                serialize_node(node)
              end,
            summary: result.summary
          }
        end

      end

    end
  end
end