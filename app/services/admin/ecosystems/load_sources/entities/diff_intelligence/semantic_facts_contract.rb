# frozen_string_literal: true

module Ecosystems
  module LoadSources
    module Entity
      module DiffIntelligence
        class SemanticFactsContract
          TYPE_ORDER = {
            identity_warning: 0,
            removed_entity: 1,
            semantic_movement: 2,
            content_change: 3,
            added_entity: 4
          }.freeze

          Result = Struct.new(
            :facts,
            keyword_init: true
          ) do
            def to_a
              facts
            end

            def each(&block)
              return enum_for(:each) unless block

              facts.each(&block)
            end

            include Enumerable

            def size
              facts.size
            end

            alias_method :length, :size

            def empty?
              facts.empty?
            end

            def [](index)
              facts[index]
            end

            def to_h
              {
                facts: facts.map(&:to_h)
              }
            end

            def as_json(*)
              to_h
            end
          end

          def self.call(source)
            new(source).call
          end

          def initialize(source)
            @source = source
          end

          def call
            Result.new(
              facts:
                normalize_source(@source)
                  .sort_by { |fact| sort_key(fact) }
                  .freeze
            )
          end

          private

          attr_reader :source

          def normalize_source(value)
            case value
            when SemanticFact
              [from_semantic_fact(value)]

            when ApplicationSemanticFact
              [value]

            when ApplicationSemanticFacts
              value.to_a

            when Array
              value.flat_map do |item|
                normalize_source(item)
              end

            else
              normalize_hash_or_event(value)
            end
          end

          def normalize_hash_or_event(value)
            if value.respond_to?(:events)
              normalize_events(value.events)

            elsif value.respond_to?(:facts)
              normalize_source(value.facts)

            elsif value.respond_to?(:type) &&
              !value.is_a?(Hash)
              [from_object(value)]

            elsif value.respond_to?(:to_h)
              normalize_hash(value.to_h)

            else
              raise ArgumentError,
                    "cannot convert #{value.class} into semantic facts"
            end
          end

          def normalize_events(events)
            Array(events).flat_map do |event|
              normalize_event(event)
            end
          end

          def normalize_event(event)
            hash =
              event.respond_to?(:to_h) ?
                event.to_h :
                event

            hash =
              symbolize_keys(hash)

            case hash[:type]&.to_sym
            when :matched
              normalize_matched_event(hash)

            when :moved
              [build_movement(hash)]

            when :added
              [build_added(hash)]

            when :removed
              [build_removed(hash)]

            when :identity_warning
              [build_warning(hash)]

            else
              normalize_hash(hash)
            end
          end

          def normalize_matched_event(event)
            facts = []

            if event[:position_changed]
              facts <<
                build_movement(
                  event.merge(
                    type: :semantic_movement
                  )
                )
            end

            Array(event[:changes]).each do |change|
              change =
                symbolize_keys(change)

              facts <<
                build_change(
                  change.merge(
                    path:
                      join_paths(
                        event[:path],
                        change[:path]
                      )
                  )
                )
            end

            facts
          end

          def normalize_hash(hash)
            hash =
              symbolize_keys(hash)

            type =
              normalize_type(
                hash[:type] ||
                  hash[:status]
              )

            case type
            when :content_change
              [build_change(hash)]

            when :semantic_movement
              [build_movement(hash)]

            when :added_entity
              [build_added(hash)]

            when :removed_entity
              [build_removed(hash)]

            when :identity_warning
              [build_warning(hash)]

            else
              raise ArgumentError,
                    "unsupported semantic fact: #{hash.inspect}"
            end
          end

          def from_semantic_fact(fact)
            ApplicationSemanticFact.new(
              type: fact.type,
              path: fact.path,
              identity:
                fact.respond_to?(:identity) ?
                  fact.identity :
                  nil,
              old_index:
                fact.respond_to?(:old_index) ?
                  fact.old_index :
                  nil,
              new_index:
                fact.respond_to?(:new_index) ?
                  fact.new_index :
                  nil,
              old_value:
                fact.respond_to?(:old_value) ?
                  fact.old_value :
                  nil,
              new_value:
                fact.respond_to?(:new_value) ?
                  fact.new_value :
                  nil,
              metadata:
                fact.respond_to?(:metadata) ?
                  fact.metadata :
                  {}
            )
          end

          def from_object(object)
            ApplicationSemanticFact.new(
              type:
                normalize_type(object.type),

              path:
                object.respond_to?(:path) ?
                  object.path :
                  [],

              identity:
                object.respond_to?(:identity) ?
                  object.identity :
                  nil,

              old_index:
                object.respond_to?(:old_index) ?
                  object.old_index :
                  nil,

              new_index:
                object.respond_to?(:new_index) ?
                  object.new_index :
                  nil,

              old_value:
                object.respond_to?(:old_value) ?
                  object.old_value :
                  nil,

              new_value:
                object.respond_to?(:new_value) ?
                  object.new_value :
                  nil,

              metadata:
                object.respond_to?(:metadata) ?
                  object.metadata :
                  {}
            )
          end

          def build_change(hash)
            ApplicationSemanticFact.new(
              type: :content_change,
              path: normalize_path(hash[:path]),
              identity: hash[:identity],
              old_value: hash[:old_value],
              new_value: hash[:new_value],
              metadata: hash[:metadata] || {}
            )
          end

          def build_movement(hash)
            ApplicationSemanticFact.new(
              type: :semantic_movement,
              path: normalize_path(hash[:path]),
              identity: hash[:identity],
              old_index: hash[:old_index],
              new_index: hash[:new_index],
              metadata: hash[:metadata] || {}
            )
          end

          def build_added(hash)
            ApplicationSemanticFact.new(
              type: :added_entity,
              path: normalize_path(hash[:path]),
              identity: hash[:identity],
              new_index: hash[:new_index],
              new_value:
                hash[:new_item] ||
                  hash[:new_value],
              metadata: hash[:metadata] || {}
            )
          end

          def build_removed(hash)
            ApplicationSemanticFact.new(
              type: :removed_entity,
              path: normalize_path(hash[:path]),
              identity: hash[:identity],
              old_index: hash[:old_index],
              old_value:
                hash[:old_item] ||
                  hash[:old_value],
              metadata: hash[:metadata] || {}
            )
          end

          def build_warning(hash)
            metadata =
              (hash[:metadata] || {}).merge(
                warning_code: hash[:code],
                side: hash[:side],
                indexes: hash[:indexes],
                reason: hash[:reason]
              ).compact

            ApplicationSemanticFact.new(
              type: :identity_warning,
              path: normalize_path(hash[:path]),
              identity: hash[:identity],
              metadata: metadata
            )
          end

          def normalize_type(value)
            case value.to_s.to_sym
            when :changed,
              :content_changed,
              :content_change
              :content_change

            when :moved,
              :movement,
              :semantic_movement
              :semantic_movement

            when :added,
              :added_entity
              :added_entity

            when :removed,
              :removed_entity
              :removed_entity

            when :identity_warning,
              :warning,
              :identity_issue,
              :duplicate_identity,
              :missing_identity,
              :ambiguous_identity
              :identity_warning

            else
              raise ArgumentError,
                    "unsupported semantic fact status: #{value.inspect}"
            end
          end

          def normalize_path(path)
            Array(path)
              .flat_map do |part|
              part.to_s.split(".")
            end
              .reject(&:empty?)
          end

          def join_paths(left, right)
            normalize_path(
              Array(left) +
                Array(right)
            )
          end

          def symbolize_keys(value)
            return value unless value.respond_to?(:each)

            value.each_with_object({}) do |(key, item), result|
              result[key.to_sym] = item
            end
          end

          def sort_key(fact)
            [
              fact.path.join("\0"),
              TYPE_ORDER.fetch(
                fact.type,
                99
              ),
              fact.identity.to_s,
              fact.old_index || -1,
              fact.new_index || -1,
              stable_value(fact.old_value),
              stable_value(fact.new_value),
              stable_value(fact.metadata)
            ]
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
                .map { |item| stable_value(item) }
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