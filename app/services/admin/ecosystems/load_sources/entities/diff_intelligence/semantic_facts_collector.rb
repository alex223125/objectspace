# frozen_string_literal: true

module Ecosystems
  module LoadSources
    module Entity
      module DiffIntelligence
        class SemanticFactsCollector
          def self.call(root)
            new(root).call
          end

          def initialize(root)
            @root = root
          end

          def call
            facts = []

            walk(@root) do |node|
              collect_node_facts(
                node,
                facts
              )
            end

            facts
          end

          private

          attr_reader :root

          def walk(node, &block)
            return unless node

            yield node

            node.children.each do |child|
              walk(child, &block)
            end
          end

          def collect_node_facts(
            node,
            facts
          )
            metadata =
              node.metadata || {}

            classification =
              metadata[:classification]

            if identity_warning_classification?(classification)
              facts << identity_warning_fact(
                node
              )
            end

            if node.status == :moved
              facts << SemanticFact.new(
                type: :semantic_movement,
                path: node.path,
                identity: metadata[:identity],
                old_index: metadata[:old_index],
                new_index: metadata[:new_index],
                metadata: {
                  classification: :moved
                }
              )
            end

            if node.status == :added &&
              entity_node?(node)

              facts << SemanticFact.new(
                type: :added_entity,
                path: node.path,
                identity: metadata[:identity],
                new_index: metadata[:new_index],
                metadata: {
                  classification: :added
                }
              )
            end

            if node.status == :removed &&
              entity_node?(node)

              facts << SemanticFact.new(
                type: :removed_entity,
                path: node.path,
                identity: metadata[:identity],
                old_index: metadata[:old_index],
                metadata: {
                  classification: :removed
                }
              )
            end

            if node.status == :changed &&
              classification.nil? &&
              !identity_container_node?(node)

              facts << SemanticFact.new(
                type: :content_change,
                path: node.path,
                identity: metadata[:identity],
                old_index: metadata[:old_index],
                new_index: metadata[:new_index],
                metadata: {
                  classification: :changed
                }
              )
            end
          end

          def identity_warning_classification?(
            classification
          )
            [
              :duplicate_identity,
              :missing_identity,
              :ambiguous_identity
            ].include?(classification)
          end

          def identity_warning_fact(node)
            metadata =
              node.metadata || {}

            SemanticFact.new(
              type: :identity_warning,
              path: node.path,
              identity: metadata[:identity],
              old_index: metadata[:indexes].is_a?(Array) ?
                           metadata[:indexes].first :
                           nil,
              new_index: nil,
              metadata: {
                classification:
                  metadata[:classification],
                code:
                  metadata[:code] ||
                    metadata[:classification],
                reason:
                  metadata[:reason],
                side:
                  metadata[:side],
                indexes:
                  metadata[:indexes]
              }.compact
            )
          end

          def entity_node?(node)
            metadata =
              node.metadata || {}

            metadata.key?(:identity) ||
              metadata.key?(:old_index) ||
              metadata.key?(:new_index)
          end

          def identity_container_node?(node)
            metadata =
              node.metadata || {}

            metadata[:array_mode] == :identity
          end
        end
      end
    end
  end
end