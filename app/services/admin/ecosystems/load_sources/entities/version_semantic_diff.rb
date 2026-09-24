# frozen_string_literal: true

module Ecosystems
  module LoadSources
    module Entities

      class VersionSemanticDiff

        STATUSES = %w[
          unchanged
          changed
          added
          removed
          moved
        ].freeze

        IDENTITY_KEYS = %w[
          id
          uuid
          key
          slug
          code
          name
        ].freeze

        attr_reader :left_version, :right_version

        def initialize(left_version:, right_version:)
          @left_version = left_version
          @right_version = right_version
        end

        # ==========================================================
        # PUBLIC API
        # ==========================================================

        def call
          compare_values(
            left_version.snapshot || {},
            right_version.snapshot || {},
            ""
          )
        end

        def result
          nodes = flatten(call)

          {
            nodes: nodes,
            statistics: statistics(nodes)
          }
        end

        # ==========================================================
        # COMPARISON
        # ==========================================================

        private

        def compare_values(left, right, path)
          if left.is_a?(Hash) && right.is_a?(Hash)
            compare_hashes(left, right, path)

          elsif left.is_a?(Array) && right.is_a?(Array)
            compare_arrays(left, right, path)

          elsif left == right
            node(
              path: path,
              status: "unchanged",
              old_value: left,
              new_value: right,
              value_type: value_type(left)
            )

          else
            node(
              path: path,
              status: "changed",
              old_value: left,
              new_value: right,
              value_type: value_type(right || left)
            )
          end
        end

        # ==========================================================
        # HASHES
        # ==========================================================

        def compare_hashes(left, right, path)
          keys =
            (
              left.keys.map(&:to_s) +
                right.keys.map(&:to_s)
            ).uniq.sort

          children = []

          keys.each do |key|
            child_path =
              path.blank? ? key : "#{path}.#{key}"

            left_present =
              hash_key_present?(left, key)

            right_present =
              hash_key_present?(right, key)

            if left_present && !right_present
              children << node(
                path: child_path,
                status: "removed",
                old_value: hash_value(left, key),
                new_value: nil,
                value_type: value_type(hash_value(left, key))
              )

            elsif !left_present && right_present
              children << node(
                path: child_path,
                status: "added",
                old_value: nil,
                new_value: hash_value(right, key),
                value_type: value_type(hash_value(right, key))
              )

            else
              children << compare_values(
                hash_value(left, key),
                hash_value(right, key),
                child_path
              )
            end
          end

          node(
            path: path,
            status: aggregate_status(children),
            old_value: left,
            new_value: right,
            value_type: "object",
            children: children
          )
        end

        # ==========================================================
        # ARRAYS
        # ==========================================================

        def compare_arrays(left, right, path)
          if identifiable_array?(left) || identifiable_array?(right)
            compare_identifiable_arrays(left, right, path)
          else
            compare_indexed_arrays(left, right, path)
          end
        end

        # ==========================================================
        # IDENTIFIABLE ARRAYS
        # ==========================================================

        def compare_identifiable_arrays(left, right, path)
          left_items =
            index_array_items(left)

          right_items =
            index_array_items(right)

          keys =
            (
              left_items.keys +
                right_items.keys
            ).uniq

          children = []

          keys.each do |identity|
            left_item =
              left_items[identity]

            right_item =
              right_items[identity]

            child_path =
              "#{path}[#{identity}]"

            if left_item && !right_item
              children << node(
                path: child_path,
                status: "removed",
                old_value: left_item[:value],
                new_value: nil,
                value_type: value_type(left_item[:value]),
                identity: identity
              )

            elsif !left_item && right_item
              children << node(
                path: child_path,
                status: "added",
                old_value: nil,
                new_value: right_item[:value],
                value_type: value_type(right_item[:value]),
                identity: identity
              )

            else
              status_node =
                compare_values(
                  left_item[:value],
                  right_item[:value],
                  child_path
                )

              if left_item[:index] != right_item[:index] &&
                status_node[:status] == "unchanged"

                status_node[:status] = "moved"

                status_node[:old_index] =
                  left_item[:index]

                status_node[:new_index] =
                  right_item[:index]
              end

              children << status_node
            end
          end

          node(
            path: path,
            status: aggregate_status(children),
            old_value: left,
            new_value: right,
            value_type: "array",
            children: children
          )
        end

        # ==========================================================
        # INDEXED ARRAYS
        # ==========================================================

        def compare_indexed_arrays(left, right, path)
          max_length =
            [left.length, right.length].max

          children = []

          max_length.times do |index|
            child_path =
              "#{path}[#{index}]"

            left_present =
              index < left.length

            right_present =
              index < right.length

            if left_present && !right_present
              children << node(
                path: child_path,
                status: "removed",
                old_value: left[index],
                new_value: nil,
                value_type: value_type(left[index])
              )

            elsif !left_present && right_present
              children << node(
                path: child_path,
                status: "added",
                old_value: nil,
                new_value: right[index],
                value_type: value_type(right[index])
              )

            else
              children << compare_values(
                left[index],
                right[index],
                child_path
              )
            end
          end

          node(
            path: path,
            status: aggregate_status(children),
            old_value: left,
            new_value: right,
            value_type: "array",
            children: children
          )
        end

        # ==========================================================
        # ARRAY IDENTITY
        # ==========================================================

        def identifiable_array?(array)
          array.any? do |item|
            item.is_a?(Hash) &&
              identity_for(item).present?
          end
        end

        def index_array_items(array)
          result = {}

          array.each_with_index do |item, index|
            identity =
              identity_for(item)

            next if identity.blank?

            identity =
              identity.to_s

            # Duplicate identities are handled by
            # falling back to an index-specific key.
            identity =
              if result.key?(identity)
                "#{identity}##{index}"
              else
                identity
              end

            result[identity] = {
              value: item,
              index: index
            }
          end

          # Non-identifiable array entries are retained.
          array.each_with_index do |item, index|
            next if identity_for(item).present?

            result["index:#{index}"] = {
              value: item,
              index: index
            }
          end

          result
        end

        def identity_for(item)
          return nil unless item.is_a?(Hash)

          IDENTITY_KEYS.each do |key|
            value =
              hash_value(item, key)

            return "#{key}:#{value}" if value.present?
          end

          nil
        end

        # ==========================================================
        # FLATTEN
        # ==========================================================

        def flatten(root)
          nodes = []

          walk_nodes(root, nodes)

          nodes
        end

        def walk_nodes(node, output)
          output << node

          Array(node[:children]).each do |child|
            walk_nodes(child, output)
          end
        end

        # ==========================================================
        # STATISTICS
        # ==========================================================

        def statistics(nodes)
          {
            total: nodes.count,
            changed: nodes.count { |node| node[:status] == "changed" },
            added: nodes.count { |node| node[:status] == "added" },
            removed: nodes.count { |node| node[:status] == "removed" },
            moved: nodes.count { |node| node[:status] == "moved" },
            unchanged: nodes.count do |node|
              node[:status] == "unchanged"
            end
          }
        end

        # ==========================================================
        # STATUS
        # ==========================================================

        def aggregate_status(children)
          return "unchanged" if children.empty?

          statuses =
            children.map { |child| child[:status] }

          return "changed" if statuses.include?("changed")
          return "added" if statuses.all? { |status| status == "added" }
          return "removed" if statuses.all? { |status| status == "removed" }
          return "moved" if statuses.include?("moved")

          "unchanged"
        end

        # ==========================================================
        # NODE
        # ==========================================================

        def node(
          path:,
          status:,
          old_value:,
          new_value:,
          value_type:,
          children: [],
          identity: nil
        )
          {
            path: path,
            status: status,
            old_value: old_value,
            new_value: new_value,
            value_type: value_type,
            children: children,
            identity: identity
          }.compact
        end

        # ==========================================================
        # HASH HELPERS
        # ==========================================================

        def hash_key_present?(hash, key)
          hash.key?(key) || hash.key?(key.to_sym)
        end

        def hash_value(hash, key)
          return hash[key] if hash.key?(key)
          return hash[key.to_sym] if hash.key?(key.to_sym)

          nil
        end

        # ==========================================================
        # VALUE TYPE
        # ==========================================================

        def value_type(value)
          case value
          when Hash
            "object"
          when Array
            "array"
          when TrueClass, FalseClass
            "boolean"
          when Numeric
            "number"
          when NilClass
            "null"
          when Time, DateTime
            "datetime"
          else
            "string"
          end
        end

      end

    end
  end
end