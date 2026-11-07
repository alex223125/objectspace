# frozen_string_literal: true

module Ecosystems
  module LoadSources
    module Entity
      module DiffIntelligence
        class ApplicationDiffPayload
          TYPE_ORDER = {
            identity_warning: 0,
            removed_entity: 1,
            semantic_movement: 2,
            content_change: 3,
            added_entity: 4
          }.freeze

          attr_reader :diff

          def self.call(
            diff:,
            old_version: nil,
            new_version: nil,
            insight: nil
          )
            new(
              diff: diff,
              old_version: old_version,
              new_version: new_version,
              insight: insight
            ).call
          end

          def initialize(
            diff:,
            old_version: nil,
            new_version: nil,
            insight: nil
          )
            @diff = diff
            @old_version = old_version
            @new_version = new_version
            @insight = insight
          end

          def call
            {
              version: version_payload,
              summary: summary_payload,
              changes: changes_payload,
              movements: movements_payload,
              additions: additions_payload,
              removals: removals_payload,
              warnings: warnings_payload,
              facts: facts_payload
            }
          end

          private

          attr_reader(
            :old_version,
            :new_version,
            :insight
          )

          # ==========================================================
          # VERSION
          # ==========================================================

          def version_payload
            {
              old: version_attributes(old_version),
              new: version_attributes(new_version)
            }
          end

          def version_attributes(version)
            return nil unless version

            {
              id:
                version.respond_to?(:id) ?
                  version.id :
                  nil,

              version_number:
                if version.respond_to?(:version_number)
                  version.version_number
                end
            }
          end

          # ==========================================================
          # SUMMARY
          # ==========================================================

          def summary_payload
            counts = {
              total: 0,
              changed: 0,
              unchanged: 0,
              added: 0,
              removed: 0,
              moved: 0,
              warnings: 0
            }

            facts.each do |fact|
              case fact_type(fact)
              when :content_change
                counts[:changed] += 1

              when :semantic_movement
                counts[:moved] += 1

              when :added_entity
                counts[:added] += 1

              when :removed_entity
                counts[:removed] += 1

              when :identity_warning
                counts[:warnings] += 1
              end
            end

            counts[:total] =
              facts.length

            counts
          end

          # ==========================================================
          # CHANGES
          # ==========================================================

          def changes_payload
            facts
              .select do |fact|
              fact_type(fact) == :content_change
            end
              .map(&:to_h)
          end

          # ==========================================================
          # MOVEMENTS
          # ==========================================================

          def movements_payload
            facts
              .select do |fact|
              fact_type(fact) == :semantic_movement
            end
              .map(&:to_h)
          end

          # ==========================================================
          # ADDITIONS
          # ==========================================================

          def additions_payload
            facts
              .select do |fact|
              fact_type(fact) == :added_entity
            end
              .map(&:to_h)
          end

          # ==========================================================
          # REMOVALS
          # ==========================================================

          def removals_payload
            facts
              .select do |fact|
              fact_type(fact) == :removed_entity
            end
              .map(&:to_h)
          end

          # ==========================================================
          # WARNINGS
          # ==========================================================

          def warnings_payload
            facts
              .select do |fact|
              fact_type(fact) == :identity_warning
            end
              .map(&:to_h)
          end

          # ==========================================================
          # ALL FACTS
          # ==========================================================

          def facts_payload
            facts.map(&:to_h)
          end

          # ==========================================================
          # FACT NORMALIZATION
          # ==========================================================

          def facts
            source =
              if diff.respond_to?(:facts)
                diff.facts
              elsif diff.respond_to?(:to_a)
                diff.to_a
              elsif diff.respond_to?(:to_h)
                extract_facts_from_hash(
                  diff.to_h
                )
              else
                []
              end

            Array(source)
              .map { |fact| normalize_fact(fact) }
              .compact
              .sort_by { |fact| sort_key(fact) }
          end

          def normalize_fact(fact)
            return nil unless fact.respond_to?(:to_h)

            hash =
              normalize_hash(
                fact.to_h
              )

            {
              type:
                normalize_type(
                  hash[:type]
                ),

              path:
                normalize_path(
                  hash[:path]
                ),

              identity:
                hash[:identity],

              old_index:
                hash[:old_index],

              new_index:
                hash[:new_index],

              old_value:
                hash[:old_value],

              new_value:
                hash[:new_value],

              metadata:
                normalize_hash(
                  hash[:metadata] || {}
                )
            }
          end

          def extract_facts_from_hash(hash)
            normalized =
              normalize_hash(hash)

            Array(
              normalized[:facts]
            )
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

          def fact_type(fact)
            normalize_type(
              fact[:type]
            )
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
          # HASH NORMALIZATION
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
                fact_type(fact),
                99
              ),

              fact[:identity].to_s,

              integer_sort_value(
                fact[:old_index]
              ),

              integer_sort_value(
                fact[:new_index]
              ),

              stable_value(
                fact[:old_value]
              ),

              stable_value(
                fact[:new_value]
              ),

              stable_value(
                fact[:metadata]
              )
            ]
          end

          def integer_sort_value(value)
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
        end
      end
    end
  end
end