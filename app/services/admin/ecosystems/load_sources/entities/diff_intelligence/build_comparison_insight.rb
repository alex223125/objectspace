# frozen_string_literal: true

module Ecosystems
  module LoadSources
    module Entity
      module DiffIntelligence
        class BuildComparisonInsight
          Signal =
            Struct.new(
              :type,
              :path,
              :points,
              :metadata,
              keyword_init: true
            )

          Insight =
            Struct.new(
              :counts,
              :signals,
              :total_points,
              keyword_init: true
            )

          POINTS = {
            "changed" => 1,
            "moved" => 2,
            "added" => 2,
            "removed" => 2,
            "identity_warning" => 0
          }.freeze

          def self.call(result:)
            new(result: result).call
          end

          def initialize(result:)
            @result = result
          end

          def call
            counts = {
              changed: 0,
              moved: 0,
              added: 0,
              removed: 0,
              identity_warning: 0
            }

            signals = []

            Array(@result.facts).each do |raw_fact|
              fact =
                normalize_fact(raw_fact)

              status =
                fact.status.to_s

              key =
                status.to_sym

              counts[key] = counts.fetch(key, 0) + 1

              signals << Signal.new(
                type: fact.type,
                path: fact.path.join("."),
                points: POINTS.fetch(status, 0),
                metadata: fact.metadata
              )
            end

            signals =
              signals.sort_by do |signal|
                [
                  signal.path,
                  signal.type.to_s
                ]
              end

            total_points =
              signals.sum(&:points)

            Insight.new(
              counts: counts,
              signals: signals,
              total_points: total_points
            )
          end

          private

          def normalize_fact(raw_fact)
            return raw_fact if raw_fact.is_a?(SemanticFact)

            hash =
              raw_fact.respond_to?(:to_h) ?
                raw_fact.to_h :
                {}

            hash =
              hash.transform_keys(&:to_sym)

            status =
              hash[:status] ||
                hash[:type]

            type =
              case status.to_s
              when "changed"
                :content_change
              when "moved"
                :semantic_movement
              when "added"
                :added_entity
              when "removed"
                :removed_entity
              when "identity_warning"
                :identity_warning
              else
                status.to_sym
              end

            SemanticFact.new(
              type: type,
              path: hash[:path],
              identity: hash[:identity],
              old_index: hash[:old_index],
              new_index: hash[:new_index],
              old_value: hash[:old_value],
              new_value: hash[:new_value],
              metadata: hash[:metadata] || {}
            )
          end
        end
      end
    end
  end
end