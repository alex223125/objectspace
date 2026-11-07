module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module ResearchCollections
          class RelationshipDetector
            def initialize(collection)
              @collection = collection
            end

            def call
              workspaces = WorkspaceAdapter
                             .new(collection)
                             .workspaces

              relationships = []

              workspaces.combination(2).each do |source, target|
                relationship = infer_relationship(source, target)

                next unless relationship

                relationships << {
                  source_workspace: source,
                  target_workspace: target,
                  relationship_type: relationship[:type],
                  confidence: relationship[:confidence],
                  note: relationship[:note]
                }
              end

              relationships
            end

            private

            attr_reader :collection

            def infer_relationship(source, target)
              source_name = workspace_name(source)
              target_name = workspace_name(target)

              if source_name.casecmp(target_name).zero?
                {
                  type: "duplicates",
                  confidence: "high",
                  note: "Workspace names are identical."
                }
              elsif normalized_overlap(source_name, target_name) > 0
                {
                  type: "related",
                  confidence: "medium",
                  note: "Workspace names share meaningful terms."
                }
              end
            end

            def workspace_name(workspace)
              WorkspaceAdapter
                .new(collection)
                .workspace_name(workspace)
            end

            def normalized_overlap(left, right)
              left_words = normalize(left)
              right_words = normalize(right)

              return 0 if left_words.empty? || right_words.empty?

              overlap = (left_words & right_words).length

              overlap.to_f / [left_words.length, right_words.length].min
            end

            def normalize(value)
              value.to_s
                   .downcase
                   .scan(/[a-z0-9]{4,}/)
                   .uniq
            end
          end
        end
      end
    end
  end
end