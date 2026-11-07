# frozen_string_literal: true

module Ecosystems
  module LoadSources
    module Entity
      module DiffIntelligence
        class SemanticComparator
          Node =
            Struct.new(
              :key,
              :status,
              :children,
              :metadata,
              :old_value,
              :new_value,
              keyword_init: true
            )

          def initialize(configuration:)
            @configuration = configuration
          end

          def call(old_snapshot, new_snapshot)
            compare_hash(
              old_snapshot,
              new_snapshot
            )
          end

          private

          def compare_hash(old_value, new_value, key = nil, path = [])
            if old_value.is_a?(Hash) && new_value.is_a?(Hash)
              keys =
                (
                  old_value.keys.map(&:to_s) |
                    new_value.keys.map(&:to_s)
                ).sort

              children =
                keys.map do |child_key|
                  old_key = fetch_key(old_value, child_key)
                  new_key = fetch_key(new_value, child_key)

                  compare_value(
                    old_key[:exists] ? old_key[:value] : nil,
                    new_key[:exists] ? new_key[:value] : nil,
                    child_key,
                    path + [child_key],
                    old_key[:exists],
                    new_key[:exists]
                  )
                end

              status =
                children.any? { |child| child.status != :unchanged } ?
                  :changed :
                  :unchanged

              Node.new(
                key: key,
                status: status,
                children: children,
                metadata: {},
                old_value: old_value,
                new_value: new_value
              )
            else
              compare_value(
                old_value,
                new_value,
                key,
                path,
                !old_value.nil?,
                !new_value.nil?
              )
            end
          end

          def compare_value(
            old_value,
            new_value,
            key,
            path,
            old_exists,
            new_exists
          )
            if old_exists && !new_exists
              return Node.new(
                key: key,
                status: :removed,
                children: [],
                metadata: {},
                old_value: old_value,
                new_value: nil
              )
            end

            if !old_exists && new_exists
              return Node.new(
                key: key,
                status: :added,
                children: [],
                metadata: {},
                old_value: nil,
                new_value: new_value
              )
            end

            if old_value.is_a?(Array) && new_value.is_a?(Array)
              return compare_array(
                old_value,
                new_value,
                key,
                path
              )
            end

            if old_value.is_a?(Hash) && new_value.is_a?(Hash)
              return compare_hash(
                old_value,
                new_value,
                key,
                path
              )
            end

            status =
              old_value == new_value ?
                :unchanged :
                :changed

            Node.new(
              key: key,
              status: status,
              children: [],
              metadata: {},
              old_value: old_value,
              new_value: new_value
            )
          end

          def compare_array(old_items, new_items, key, path)
            identity =
              @configuration.identity_for(
                path.join(".")
              )

            unless identity
              return compare_positional_array(
                old_items,
                new_items,
                key,
                path
              )
            end

            result =
              SemanticArrayDiff.call(
                old_items: old_items,
                new_items: new_items,
                path: path.join("."),
                identity: identity
              )

            children =
              result.events.map do |event|
                event_node(
                  event,
                  path
                )
              end

            status =
              if result.events.any? do |event|
                event[:state] != :unchanged
              end
                :changed
              else
                :unchanged
              end

            Node.new(
              key: key,
              status: status,
              children: children,
              metadata: {
                identity: identity
              },
              old_value: old_items,
              new_value: new_items
            )
          end

          def compare_positional_array(
            old_items,
            new_items,
            key,
            path
          )
            length =
              [old_items.length, new_items.length].max

            children =
              (0...length).map do |index|
                old_exists = index < old_items.length
                new_exists = index < new_items.length

                compare_value(
                  old_exists ? old_items[index] : nil,
                  new_exists ? new_items[index] : nil,
                  index.to_s,
                  path + [index.to_s],
                  old_exists,
                  new_exists
                )
              end

            status =
              children.any? { |child| child.status != :unchanged } ?
                :changed :
                :unchanged

            Node.new(
              key: key,
              status: status,
              children: children,
              metadata: {},
              old_value: old_items,
              new_value: new_items
            )
          end

          def event_node(event, path)
            case event[:type]
            when :matched
              metadata = {
                identity: event[:identity]
              }

              metadata[:position_changed] =
                true if event[:position_changed]

              children =
                event[:changes].map do |change|
                  Node.new(
                    key: change[:path].split(".").last,
                    status: change[:state],
                    children: [],
                    metadata: {},
                    old_value: change[:old_value],
                    new_value: change[:new_value]
                  )
                end

              Node.new(
                key: event[:identity],
                status:
                  event[:state] == :moved ?
                    :moved :
                    event[:state],
                children: children,
                metadata: metadata,
                old_value: event[:old_item],
                new_value: event[:new_item]
              )
            when :added
              Node.new(
                key: event[:identity],
                status: :added,
                children: [],
                metadata: {
                  identity: event[:identity]
                },
                old_value: nil,
                new_value: event[:new_item]
              )
            when :removed
              Node.new(
                key: event[:identity],
                status: :removed,
                children: [],
                metadata: {
                  identity: event[:identity]
                },
                old_value: event[:old_item],
                new_value: nil
              )
            when :identity_warning
              Node.new(
                key: event[:identity],
                status: :identity_warning,
                children: [],
                metadata: {
                  classification: event[:state],
                  identity: event[:identity],
                  side: event[:side],
                  indexes: event[:indexes],
                  index: event[:index],
                  reason: event[:reason]
                },
                old_value: nil,
                new_value: nil
              )
            else
              Node.new(
                key: event[:identity],
                status: :changed,
                children: [],
                metadata: {},
                old_value: event[:old_item],
                new_value: event[:new_item]
              )
            end
          end

          def fetch_key(hash, key)
            if hash.key?(key)
              {
                exists: true,
                value: hash[key]
              }
            elsif hash.key?(key.to_sym)
              {
                exists: true,
                value: hash[key.to_sym]
              }
            else
              {
                exists: false,
                value: nil
              }
            end
          end
        end
      end
    end
  end
end