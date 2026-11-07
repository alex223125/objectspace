# frozen_string_literal: true

module Ecosystems
  module LoadSources
    module Entity
      module DiffIntelligence
        class ApplicationSemanticFacts
          TYPE_ORDER = {
            identity_warning: 0,
            removed_entity: 1,
            semantic_movement: 2,
            content_change: 3,
            added_entity: 4
          }.freeze

          attr_reader :facts

          def initialize(facts = [])
            @facts =
              Array(facts)
                .flat_map { |fact| normalize_fact(fact) }
                .compact
                .sort_by { |fact| sort_key(fact) }
                .freeze
          end

          def empty?
            facts.empty?
          end

          def size
            facts.size
          end

          alias_method :length, :size

          def each(&block)
            facts.each(&block)
          end

          include Enumerable

          def [](index)
            facts[index]
          end

          def to_a
            facts.dup
          end

          def to_h
            {
              facts: facts.map(&:to_h),
              total: facts.length
            }
          end

          def as_json(*)
            to_h
          end

          private

          def normalize_fact(fact)
            return [fact] if fact.is_a?(ApplicationSemanticFact)

            attributes =
              if fact.respond_to?(:to_h)
                fact.to_h
              elsif fact.respond_to?(:as_json)
                fact.as_json
              else
                raise ArgumentError,
                      "Unsupported semantic fact object: #{fact.class.name}"
              end

            attributes =
              attributes.respond_to?(:to_h) ?
                attributes.to_h :
                {}

            [
              ApplicationSemanticFact.new(
                type:
                  fetch_attribute(
                    attributes,
                    :type
                  ),

                path:
                  fetch_attribute(
                    attributes,
                    :path
                  ),

                identity:
                  fetch_attribute(
                    attributes,
                    :identity
                  ),

                old_index:
                  fetch_attribute(
                    attributes,
                    :old_index
                  ),

                new_index:
                  fetch_attribute(
                    attributes,
                    :new_index
                  ),

                old_value:
                  fetch_attribute(
                    attributes,
                    :old_value
                  ),

                new_value:
                  fetch_attribute(
                    attributes,
                    :new_value
                  ),

                metadata:
                  fetch_attribute(
                    attributes,
                    :metadata
                  ) || {}
              )
            ]
          end

          def fetch_attribute(attributes, key)
            return attributes[key] if attributes.key?(key)

            string_key =
              key.to_s

            return attributes[string_key] if attributes.key?(string_key)

            nil
          end

          def sort_key(fact)
            [
              fact.path.map(&:to_s).join("\0"),

              TYPE_ORDER.fetch(
                fact.type,
                99
              ),

              fact.identity.to_s,

              integer_sort_value(
                fact.old_index
              ),

              integer_sort_value(
                fact.new_index
              ),

              stable_value(
                fact.old_value
              ),

              stable_value(
                fact.new_value
              ),

              stable_value(
                fact.metadata
              )
            ]
          end

          def integer_sort_value(value)
            return -1 if value.nil?

            value.to_i
          end

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