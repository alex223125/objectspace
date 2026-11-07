# frozen_string_literal: true

module Ecosystems
  module LoadSources
    module Entity
      module DiffIntelligence
        class SemanticFactExtractor
          def self.call(root)
            new(root).call
          end

          def initialize(root)
            @root = root
          end

          def call
            facts = []

            walk(@root) do |node|
              facts.concat(
                facts_for(node)
              )
            end

            facts
          end

          private

          attr_reader :root

          def walk(node, &block)
            yield node

            node.children.each do |child|
              walk(child, &block)
            end
          end

          def facts_for(node)
            facts = []

            classification =
              node.metadata[:classification]

            case classification
            when :duplicate_identity
              facts << identity_warning_fact(
                node,
                warning: :duplicate_identity,
                metadata: {
                  side: node.metadata[:side],
                  indexes: node.metadata[:indexes]
                }
              )

            when :ambiguous_identity
              facts << identity_warning_fact(
                node,
                warning: :ambiguous_identity,
                metadata: {
                  old_indexes: node.metadata[:old_indexes],
                  new_indexes: node.metadata[:new_indexes]
                }
              )

            when :missing_identity
              facts << identity_warning_fact(
                node,
                warning: :missing_identity,
                metadata: {
                  old_index: node.metadata[:old_index],
                  new_index: node.metadata[:new_index]
                }
              )
            end

            if node.metadata.key?(:identity)
              case node.status
              when :moved
                facts << build_fact(
                  node,
                  classification: :semantic_movement,
                  metadata: {
                    old_index: node.metadata[:old_index],
                    new_index: node.metadata[:new_index]
                  }
                )

              when :added
                facts << build_fact(
                  node,
                  classification: :added_entity,
                  metadata: {
                    new_index: node.metadata[:new_index]
                  }
                )

              when :removed
                facts << build_fact(
                  node,
                  classification: :removed_entity,
                  metadata: {
                    old_index: node.metadata[:old_index]
                  }
                )

              when :changed
                facts << build_fact(
                  node,
                  classification: :content_change,
                  metadata: {
                    old_index: node.metadata[:old_index],
                    new_index: node.metadata[:new_index]
                  }
                )
              end
            elsif node.status == :changed &&
              node.children.empty?

              facts << build_fact(
                node,
                classification: :field_change
              )
            end

            facts
          end

          def identity_warning_fact(
            node,
            warning:,
            metadata: {}
          )
            build_fact(
              node,
              classification: :identity_warning,
              metadata: metadata.merge(
                warning: warning
              )
            )
          end

          def build_fact(
            node,
            classification:,
            metadata: {}
          )
            SemanticFact.new(
              classification: classification,
              path: normalize_path(node.path),
              identity: node.metadata[:identity],
              old_index: node.metadata[:old_index],
              new_index: node.metadata[:new_index],
              old_value: node.old_value,
              new_value: node.new_value,
              metadata: normalize_metadata(
                node.metadata.merge(metadata)
              )
            )
          end

          def normalize_path(path)
            Array(path).map(&:to_s)
          end

          def normalize_metadata(metadata)
            metadata.each_with_object({}) do |(key, value), result|
              result[key.to_sym] = value
            end
          end
        end
      end
    end
  end
end