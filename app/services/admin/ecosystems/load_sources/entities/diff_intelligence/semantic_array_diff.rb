# frozen_string_literal: true

module Ecosystems
  module LoadSources
    module Entity
      module DiffIntelligence
        class SemanticArrayDiff
          def self.call(
            old_items:,
            new_items:,
            path:,
            identity:
          )
            new(
              old_items: old_items,
              new_items: new_items,
              path: path,
              identity: identity
            ).call
          end

          def initialize(
            old_items:,
            new_items:,
            path:,
            identity:
          )
            @old_items = old_items
            @new_items = new_items
            @path = path.to_s
            @identity = identity.to_s
          end

          def call
            resolution =
              IdentityResolution.call(
                old_array: @old_items,
                new_array: @new_items,
                identity_field: @identity
              )

            events = []

            resolution.matches.each do |match|
              case match.classification
              when :moved
                changes =
                  nested_changes(
                    match.old_item,
                    match.new_item
                  )

                events << {
                  type: :matched,
                  state: changes.empty? ? :moved : :changed,
                  identity: match.identity,
                  old_index: match.old_index,
                  new_index: match.new_index,
                  old_item: match.old_item,
                  new_item: match.new_item,
                  position_changed: true,
                  changes: changes
                }
              when :unchanged
                events << {
                  type: :matched,
                  state: :unchanged,
                  identity: match.identity,
                  old_index: match.old_index,
                  new_index: match.new_index,
                  old_item: match.old_item,
                  new_item: match.new_item,
                  position_changed: false,
                  changes: []
                }
              when :added
                events << {
                  type: :added,
                  state: :added,
                  identity: match.identity,
                  new_index: match.new_index,
                  new_item: match.new_item
                }
              when :removed
                events << {
                  type: :removed,
                  state: :removed,
                  identity: match.identity,
                  old_index: match.old_index,
                  old_item: match.old_item
                }
              end
            end

            resolution.warnings.each do |warning|
              events << warning_event(warning)
            end

            events =
              events.sort_by do |event|
                [
                  event[:new_index] || Float::INFINITY,
                  event[:old_index] || Float::INFINITY,
                  event[:identity].to_s,
                  event[:type].to_s
                ]
              end

            Result.new(
              events: events,
              safe: resolution.safe?
            )
          end

          Result =
            Struct.new(
              :events,
              :safe,
              keyword_init: true
            ) do
              def safe?
                safe
              end
            end

          private

          def nested_changes(old_value, new_value, prefix = nil)
            if old_value.is_a?(Hash) && new_value.is_a?(Hash)
              keys =
                (
                  old_value.keys.map(&:to_s) |
                    new_value.keys.map(&:to_s)
                ).sort

              keys.each_with_object([]) do |key, changes|
                old_key =
                  old_value.key?(key) ? key :
                    old_value.key?(key.to_sym) ? key.to_sym :
                      nil

                new_key =
                  new_value.key?(key) ? key :
                    new_value.key?(key.to_sym) ? key.to_sym :
                      nil

                old_child =
                  old_key.nil? ? nil : old_value[old_key]

                new_child =
                  new_key.nil? ? nil : new_value[new_key]

                child_path =
                  prefix.nil? ? key : "#{prefix}.#{key}"

                if old_key.nil?
                  changes << {
                    path: child_path,
                    state: :added,
                    old_value: nil,
                    new_value: new_child
                  }
                elsif new_key.nil?
                  changes << {
                    path: child_path,
                    state: :removed,
                    old_value: old_child,
                    new_value: nil
                  }
                else
                  changes.concat(
                    nested_changes(
                      old_child,
                      new_child,
                      child_path
                    )
                  )
                end
              end
            elsif old_value != new_value
              [
                {
                  path: prefix.to_s,
                  state: :changed,
                  old_value: old_value,
                  new_value: new_value
                }
              ]
            else
              []
            end
          end

          def warning_event(warning)
            {
              type: :identity_warning,
              state:
                warning.code == :duplicate_identity ?
                  :duplicate_identity :
                  warning.code,
              code: warning.code,
              side: warning.side,
              identity: warning.identity,
              indexes: warning.indexes,
              index: warning.indexes.is_a?(Array) ?
                       warning.indexes.first :
                       nil,
              reason: warning.reason
            }
          end
        end
      end
    end
  end
end