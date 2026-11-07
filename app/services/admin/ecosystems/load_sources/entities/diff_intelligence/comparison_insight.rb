# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entity
        module DiffIntelligence
          class ComparisonInsight
            Signal =
              Struct.new(
                :type,
                :path,
                :identity,
                :points,
                :metadata,
                keyword_init: true
              )

            attr_reader :counts, :signals

            def initialize(counts:, signals:)
              @counts = counts
              @signals = signals
            end

            def total_points
              signals.sum(&:points)
            end
          end

          class BuildComparisonInsight
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
              normalized =
                Array(@result.facts).map do |fact|
                  normalize_fact(fact)
                end

              counts =
                {
                  changed: count_status(normalized, "changed"),
                  moved: count_status(normalized, "moved"),
                  added: count_status(normalized, "added"),
                  removed: count_status(normalized, "removed"),
                  identity_warning:
                    count_status(
                      normalized,
                      "identity_warning"
                    )
                }

              signals =
                normalized.map do |fact|
                  status =
                    (
                      fact[:status] ||
                        fact["status"] ||
                        fact[:type] ||
                        fact["type"]
                    ).to_s

                  ComparisonInsight::Signal.new(
                    type: status.to_sym,
                    path:
                      fact[:path] ||
                        fact["path"],
                    identity:
                      fact[:identity] ||
                        fact["identity"],
                    points: POINTS.fetch(status, 0),
                    metadata:
                      fact[:metadata] ||
                        fact["metadata"] ||
                        {}
                  )
                end

              ComparisonInsight.new(
                counts: counts,
                signals: signals
              )
            end

            private

            def normalize_fact(fact)
              if fact.is_a?(Hash)
                fact
              elsif fact.respond_to?(:to_h)
                fact.to_h
              else
                {
                  type:
                    fact.respond_to?(:type) ?
                      fact.type :
                      nil,
                  status:
                    fact.respond_to?(:status) ?
                      fact.status :
                      nil,
                  path:
                    fact.respond_to?(:path_string) ?
                      fact.path_string :
                      nil,
                  identity:
                    fact.respond_to?(:identity) ?
                      fact.identity :
                      nil,
                  metadata:
                    fact.respond_to?(:metadata) ?
                      fact.metadata :
                      {}
                }
              end
            end

            def count_status(facts, status)
              facts.count do |fact|
                (
                  fact[:status] ||
                    fact["status"] ||
                    fact[:type] ||
                    fact["type"]
                ).to_s == status
              end
            end
          end
        end
      end
    end
  end
end
