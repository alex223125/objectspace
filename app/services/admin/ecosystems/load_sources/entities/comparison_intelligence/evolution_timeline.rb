# frozen_string_literal: true

module Comparisons
  class EvolutionTimeline
    VERSION_LIMIT = 30

    def initialize(versions:, current_version: nil)
      @versions = Array(versions).compact.first(VERSION_LIMIT)
      @current_version = current_version
    end

    def call
      normalized = normalized_versions

      {
        versions: normalized,
        current_index: current_index(normalized),
        total_changes: normalized.sum { |version| version[:changes_count] },
        average_changes: average_changes(normalized),
        peak_changes: peak_changes(normalized),
        evolution_score: evolution_score(normalized),
        momentum_score: momentum_score(normalized),
        review_debt: review_debt(normalized),
        change_density: change_density(normalized),
        hotspots: hotspots(normalized),
        milestones: milestones(normalized),
        signals: signals(normalized)
      }
    end

    def value(record, attribute)
      return nil unless record.respond_to?(attribute)

      record.public_send(attribute)
    rescue StandardError
      nil
    end

    private

    attr_reader :versions, :current_version

    def normalized_versions
      versions.each_with_index.map do |version, index|
        changes = extract_changes(version)

        {
          id: value(version, :id) || "version-#{index + 1}",
          index: index,
          number: version_number(version, index),
          title: value(version, :title) || "Version #{index + 1}",
          created_at: value(version, :created_at),
          changes_count: changes.count,
          added_count: changes.count { |change| change_type(change) == "added" },
          removed_count: changes.count { |change| change_type(change) == "removed" },
          changed_count: changes.count { |change| change_type(change) == "changed" },
          moved_count: changes.count { |change| change_type(change) == "moved" },
          warning_count: changes.count { |change| warning_change?(change) },
          review_count: review_count(version, changes),
          paths: extract_paths(changes),
          is_current: current?(version),
          intensity: 0
        }
      end.tap do |items|
        max = items.map { |item| item[:changes_count] }.max.to_i

        items.each do |item|
          item[:intensity] =
            if max.zero?
              0
            else
              ((item[:changes_count].to_f / max) * 100).round
            end
        end
      end
    end

    def extract_changes(version)
      if version.respond_to?(:changes)
        Array(version.changes)
      elsif version.respond_to?(:comparison_changes)
        Array(version.comparison_changes)
      elsif version.respond_to?(:diff)
        Array(version.diff)
      else
        []
      end
    end

    def extract_paths(changes)
      changes.filter_map do |change|
        path =
          value(change, :path) ||
            value(change, :field) ||
            value(change, :key)

        path.to_s.presence
      end.uniq.first(8)
    end

    def change_type(change)
      raw =
        value(change, :change_type) ||
          value(change, :kind) ||
          value(change, :type) ||
          value(change, :status)

      raw.to_s.downcase
    end

    def warning_change?(change)
      value(change, :warning) == true ||
        value(change, :risk) == true ||
        change_type(change).include?("warning")
    end

    def review_count(version, changes)
      explicit =
        value(version, :review_count) ||
          value(version, :remaining_review_count)

      return explicit.to_i if explicit

      changes.count do |change|
        value(change, :reviewed) == false ||
          value(change, :reviewed_at).nil?
      end
    end

    def version_number(version, index)
      value(version, :version_number) ||
        value(version, :number) ||
        value(version, :position) ||
        index + 1
    end

    def current?(version)
      return true if current_version && same_record?(version, current_version)

      value(version, :current?) == true ||
        value(version, :is_current) == true
    end

    def same_record?(first, second)
      first_id = value(first, :id)
      second_id = value(second, :id)

      first_id.present? && second_id.present? && first_id.to_s == second_id.to_s
    end

    def current_index(items)
      index = items.index { |item| item[:is_current] }
      index || [items.length - 1, 0].max
    end

    def average_changes(items)
      return 0 if items.empty?

      (items.sum { |item| item[:changes_count] }.to_f / items.length).round
    end

    def peak_changes(items)
      items.map { |item| item[:changes_count] }.max.to_i
    end

    def evolution_score(items)
      return 0 if items.empty?

      intensity =
        [items.sum { |item| item[:changes_count] }, 100].min

      movement =
        items.sum { |item| item[:moved_count] } * 4

      structural =
        items.sum { |item| item[:added_count] + item[:removed_count] } * 3

      [[intensity + movement + structural, 0].max, 100].min
    end

    def momentum_score(items)
      return 0 if items.length < 2

      recent = items.last([items.length, 3].min)
      previous = items.first([items.length - recent.length, 3].max)

      recent_average =
        recent.sum { |item| item[:changes_count] }.to_f / recent.length

      return 50 if previous.empty?

      previous_average =
        previous.sum { |item| item[:changes_count] }.to_f / previous.length

      return 100 if previous_average.zero? && recent_average.positive?

      score =
        50 + ((recent_average - previous_average) / [previous_average, 1].max * 50)

      [[score.round, 0].max, 100].min
    end

    def review_debt(items)
      total =
        items.sum { |item| item[:review_count] }

      changes =
        items.sum { |item| item[:changes_count] }

      return 0 if changes.zero?

      [(total.to_f / changes * 100).round, 100].min
    end

    def change_density(items)
      return 0 if items.empty?

      active =
        items.count { |item| item[:changes_count].positive? }

      ((active.to_f / items.length) * 100).round
    end

    def hotspots(items)
      counts = Hash.new(0)

      items.each do |item|
        item[:paths].each do |path|
          counts[path] += item[:changes_count].positive? ? 1 : 0
        end
      end

      counts
        .sort_by { |_path, count| -count }
        .first(5)
        .map do |path, count|
        {
          path: path,
          activity: count
        }
      end
    end

    def milestones(items)
      return [] if items.empty?

      peak =
        items.max_by { |item| item[:changes_count] }

      result = []

      if peak && peak[:changes_count].positive?
        result << {
          type: "peak",
          version_id: peak[:id],
          label: "Peak evolution",
          description: "#{peak[:changes_count]} changes introduced"
        }
      end

      first_structural =
        items.find do |item|
          item[:added_count].positive? || item[:removed_count].positive?
        end

      if first_structural
        result << {
          type: "structural",
          version_id: first_structural[:id],
          label: "Structural shift",
          description: "Additions or removals detected"
        }
      end

      current =
        items.find { |item| item[:is_current] }

      if current
        result << {
          type: "current",
          version_id: current[:id],
          label: "Current version",
          description: "Active comparison target"
        }
      end

      result
    end

    def signals(items)
      signals = []

      evolution = evolution_score(items)
      momentum = momentum_score(items)
      debt = review_debt(items)

      if evolution >= 70
        signals << {
          type: "impact",
          icon: "🔥",
          title: "High evolution",
          description: "This entity has experienced substantial structural change."
        }
      elsif evolution >= 40
        signals << {
          type: "evolution",
          icon: "↗",
          title: "Active evolution",
          description: "The knowledge model is changing at a meaningful rate."
        }
    end

    if momentum >= 70
      signals << {
        type: "momentum",
        icon: "⚡",
        title: "Momentum rising",
        description: "Recent versions are changing faster than earlier versions."
      }
    end

    if debt >= 30
      signals << {
        type: "review",
        icon: "⚠",
        title: "Review debt",
        description: "#{debt}% of detected changes still require attention."
      }
    end

    if items.any? { |item| item[:warning_count].positive? }
      signals << {
        type: "risk",
        icon: "◈",
        title: "Risk signals",
        description: "One or more versions contain warning-level changes."
      }
    end

    signals.first(4)
  end
  end
end