# frozen_string_literal: true

module Ecosystems
  module LoadSources
    module Entity
      module DiffIntelligence
        class SemanticFactBuilder
          def self.call(result:)
            new(result: result).call
          end

          def initialize(result:)
            @result = result
          end

          def call
            facts = []

            walk(
              node: @result,
              path: [],
              facts: facts
            )

            SemanticDiffResult.new(facts: facts)
          end

          private

          def walk(node:, path:, facts:)
            current_path =
              if node.respond_to?(:key) && !node.key.nil?
                path + [node.key]
              else
                path
              end

            emit_node_fact(
              node: node,
              path: current_path,
              facts: facts
            )

            children =
              if node.respond_to?(:children)
                Array(node.children)
              else
                []
              end

            children.each do |child|
              walk(
                node: child,
                path: current_path,
                facts: facts
              )
            end
          end

          def emit_node_fact(node:, path:, facts:)
            status =
              if node.respond_to?(:status)
                node.status
              end

            metadata =
              if node.respond_to?(:metadata) && node.metadata
                node.metadata
              else
                {}
              end

            metadata =
              metadata.to_h if metadata.respond_to?(:to_h)

            metadata = {} unless metadata.is_a?(Hash)

            classification =
              metadata_value(metadata, :classification)

            case classification&.to_sym
            when :duplicate_identity
              facts << identity_warning_fact(
                path: path,
                node: node,
                metadata: metadata,
                warning_code: :duplicate_identity
              )

              return
            when :missing_identity
              facts << identity_warning_fact(
                path: path,
                node: node,
                metadata: metadata,
                warning_code: :missing_identity
              )

              return
            end

            case status&.to_sym
            when :changed
              facts << SemanticFact.new(
                type: :content_change,
                path: path,
                identity: metadata_value(metadata, :identity),
                old_index: metadata_value(metadata, :old_index),
                new_index: metadata_value(metadata, :new_index),
                old_value: value_from(node, :old_value),
                new_value: value_from(node, :new_value),
                metadata: canonical_metadata(metadata)
              )
            when :moved
              facts << SemanticFact.new(
                type: :semantic_movement,
                path: path,
                identity: metadata_value(metadata, :identity),
                old_index: metadata_value(metadata, :old_index),
                new_index: metadata_value(metadata, :new_index),
                metadata: canonical_metadata(metadata)
              )
            when :added
              facts << SemanticFact.new(
                type: :added_entity,
                path: path,
                identity: metadata_value(metadata, :identity),
                new_index: metadata_value(metadata, :new_index),
                new_value: value_from(node, :new_value),
                metadata: canonical_metadata(metadata)
              )
            when :removed
              facts << SemanticFact.new(
                type: :removed_entity,
                path: path,
                identity: metadata_value(metadata, :identity),
                old_index: metadata_value(metadata, :old_index),
                old_value: value_from(node, :old_value),
                metadata: canonical_metadata(metadata)
              )
            end
          end

          def identity_warning_fact(
            path:,
            node:,
            metadata:,
            warning_code:
          )
            SemanticFact.new(
              type: :identity_warning,
              path: path,
              identity: metadata_value(metadata, :identity),
              old_index: metadata_value(metadata, :old_index),
              new_index: metadata_value(metadata, :new_index),
              metadata: canonical_metadata(metadata).merge(
                warning_code: warning_code,
                identity_issue: warning_code.to_s
              )
            )
          end

          def metadata_value(metadata, key)
            if metadata.key?(key)
              metadata[key]
            else
              metadata[key.to_s]
            end
          end

          def value_from(node, key)
            return unless node.respond_to?(key)

            node.public_send(key)
          end

          def canonical_metadata(metadata)
            metadata.each_with_object({}) do |(key, value), result|
              result[key.to_sym] = value
            end
          end
        end
      end
    end
  end
end
