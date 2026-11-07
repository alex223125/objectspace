# frozen_string_literal: true
module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module ResearchCollections
          class WorkspaceSignals
            def initialize(collection)
              @collection = collection
            end

            def call
              intelligence = WorkspaceIntelligence.new(collection).call

              {
                generated_at: Time.current.iso8601,
                source: "research_workspaces",
                workspace_count: intelligence[:workspace_count],
                evidence_count: intelligence[:evidence_count],
                coverage_percentage: intelligence[:coverage_percentage],
                signals: build_signals(intelligence)
              }
            end

            private

            attr_reader :collection

            def build_signals(intelligence)
              signals = []

              if intelligence[:workspace_count].zero?
                signals << signal(
                  "no_workspaces",
                  "No linked research workspaces were discovered.",
                  "warning"
                )
              end

              if intelligence[:workspace_count].positive? &&
                intelligence[:evidence_count].zero?
                signals << signal(
                  "no_discovered_evidence",
                  "No evidence records were discovered through supported associations.",
                  "review"
                )
              end

              uncovered = intelligence[:evidence_by_workspace].select do |workspace|
                workspace[:evidence_count].zero?
              end

              uncovered.each do |workspace|
                signals << signal(
                  "workspace_without_evidence",
                  "#{workspace[:workspace_name]} has no discovered evidence records.",
                  "review",
                  workspace_id: workspace[:workspace_id]
                )
              end

              signals
            end

            def signal(code, message, severity, **metadata)
              {
                code: code,
                message: message,
                severity: severity
              }.merge(metadata)
            end
          end
        end
      end
    end
  end
end