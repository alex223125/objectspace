# frozen_string_literal: true

module Ecosystems
  module LoadSources
    module Entity
      module DiffIntelligence
        class ApplicationDiffPresenter
          TYPE_ORDER = {
            identity_warning: 0,
            removed_entity: 1,
            semantic_movement: 2,
            content_change: 3,
            added_entity: 4
          }.freeze

          attr_reader :payload

          def self.call(payload)
            new(payload).call
          end

          def initialize(payload)
            @payload = normalize_hash(payload)
          end

          def call
            {
              version: version,
              summary: summary,
              groups: groups,
              facts: facts,
              empty: facts.empty?
            }
          end

          private

          # ==========================================================
          # VERSION
          # ==========================================================

          def version
            source =
              normalize_hash(
                payload[:version]
              )

            {
              old: normalize_version(
                source[:old]
              ),
              new: normalize_version(
                source[:new]
              )
            }
          end

          def normalize_version(value)
            return nil unless value

            version =
              normalize_hash(value)

            {
              id: version[:id],
              version_number: version[:version_number]
            }
          end

          # ==========================================================
          # SUMMARY
          # ==========================================================

          def summary
            source =
              normalize_hash(
                payload[:summary]
              )

            {
              total: integer_value(source[:total]),
              changed: integer_value(source[:changed]),
              unchanged: integer_value(source[:unchanged]),
              added: integer_value(source[:added]),
              removed: integer_value(source[:removed]),
              moved: integer_value(source[:moved]),
              warnings: integer_value(source[:warnings])
            }
          end

          # ==========================================================
          # GROUPS
          # ==========================================================

          def groups
            {
              changes: normalize_fact_collection(
                payload[:changes]
              ),

              movements: normalize_fact_collection(
                payload[:movements]
              ),

              additions: normalize_fact_collection(
                payload[:additions]
              ),

              removals: normalize_fact_collection(
                payload[:removals]
              ),

              warnings: normalize_fact_collection(
                payload[:warnings]
              )
            }
          end

          # ==========================================================
          # FACTS
          # ==========================================================

          def facts
            normalize_fact_collection(
              payload[:facts]
            ).sort_by do |fact|
              sort_key(fact)
            end
          end

          # ==========================================================
          # FACT COLLECTION
          # ==========================================================

          def normalize_fact_collection(collection)
            Array(collection)
              .map do |fact|
              normalize_fact(fact)
            end
              .compact
          end

          # ==========================================================
          # FACT
          # ==========================================================

          def normalize_fact(fact)
            value =
              normalize_hash(fact)

            return nil if value.empty?

            {
              type:
                normalize_type(
                  value[:type]
                ),

              path:
                normalize_path(
                  value[:path]
                ),

              identity:
                value[:identity],

              old_index:
                value[:old_index],

              new_index:
                value[:new_index],

              old_value:
                value[:old_value],

              new_value:
                value[:new_value],

              metadata:
                normalize_hash(
                  value[:metadata]
                )
            }
          end

          # ==========================================================
          # TYPE
          # ==========================================================

          def normalize_type(value)
            case value.to_s
            when "changed",
              "content_changed",
              "content_change"

              :content_change

            when "moved",
              "movement",
              "semantic_movement"

              :semantic_movement

            when "added",
              "added_entity"

              :added_entity

            when "removed",
              "removed_entity"

              :removed_entity

            when "warning",
              "identity_warning"

              :identity_warning

            else
              value.to_s.to_sym
            end
          end

          # ==========================================================
          # PATH
          # ==========================================================

          def normalize_path(path)
            Array(path)
              .flatten
              .compact
              .map(&:to_s)
              .flat_map do |part|
              part.split(".")
            end
              .reject(&:empty?)
          end

          # ==========================================================
          # HASH
          # ==========================================================

          def normalize_hash(value)
            return {} unless value.respond_to?(:each)

            value.each_with_object({}) do |(key, child), result|
              result[key.to_sym] =
                case child
                when Hash
                  normalize_hash(child)

                when Array
                  child.map do |item|
                    item.is_a?(Hash) ?
                      normalize_hash(item) :
                      item
                  end

                else
                  child
                end
            end
          end

          # ==========================================================
          # SORTING
          # ==========================================================

          def sort_key(fact)
            [
              normalize_path(
                fact[:path]
              ).join("\0"),

              TYPE_ORDER.fetch(
                normalize_type(
                  fact[:type]
                ),
                99
              ),

              fact[:identity].to_s,

              index_value(
                fact[:old_index]
              ),

              index_value(
                fact[:new_index]
              ),

              stable_value(
                fact[:old_value]
              ),

              stable_value(
                fact[:new_value]
              )
            ]
          end

          # ==========================================================
          # INDEX
          # ==========================================================

          def index_value(value)
            return -1 if value.nil?

            value.to_i
          end

          # ==========================================================
          # STABLE VALUE
          # ==========================================================

          def stable_value(value)
            case value
            when Hash
              value
                .keys
                .map(&:to_s)
                .sort
                .map do |key|
                child =
                  if value.key?(key)
                    value[key]
                  elsif value.key?(key.to_sym)
                    value[key.to_sym]
                  end

                "#{key}=#{stable_value(child)}"
              end
                .join("|")

            when Array
              value
                .map do |item|
                stable_value(item)
              end
                .join("|")

            else
              value.to_s
            end
          end

          # ==========================================================
          # INTEGER
          # ==========================================================

          def integer_value(value)
            return 0 if value.nil?

            value.to_i
          end
        end
      end
    end
  end
end