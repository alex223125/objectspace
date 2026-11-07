# frozen_string_literal: true

module Ecosystems
  module LoadSources
    module Entity
      module DiffIntelligence
        module Gamification
          class GamificationResult
            attr_reader :signals

            def initialize(signals:)
              @signals = Array(signals)
            end

            def total_points
              signals.sum(&:points)
            end

            def signal_count
              signals.size
            end

            def by_type(type)
              signals.select { |signal| signal.type == type.to_s }
            end

            def types
              signals.map(&:type).uniq
            end

            def to_h
              {
                total_points: total_points,
                signal_count: signal_count,
                signals: signals.map(&:to_h)
              }
            end
          end
        end
      end
    end
  end
end