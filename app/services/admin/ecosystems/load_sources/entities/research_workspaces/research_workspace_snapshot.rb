module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module ResearchWorkspace
          class ResearchWorkspaceSnapshot
            SNAPSHOT_VERSION = 1

            class << self
              def capture(workspace, label: nil)
                {
                  "id" => SecureRandom.uuid,
                  "version" => SNAPSHOT_VERSION,
                  "label" => label.presence || default_label(workspace),
                  "created_at" => Time.current.iso8601,
                  "workspace" => workspace_attributes(workspace),
                  "items" => workspace.items.includes(
                    :annotations,
                    :evidences
                  ).map { |item| item_attributes(item) }
                }
              end

              private

              def default_label(workspace)
                "#{workspace.title} — #{Time.current.strftime('%Y-%m-%d %H:%M')}"
              end

              def workspace_attributes(workspace)
                {
                  "id" => workspace.id,
                  "title" => workspace.title,
                  "slug" => workspace.slug,
                  "status" => workspace.status,
                  "created_at" => workspace.created_at&.iso8601,
                  "updated_at" => workspace.updated_at&.iso8601,
                  "last_opened_at" => workspace.last_opened_at&.iso8601,
                  "progress" => workspace.progress,
                  "research_strength" => workspace.research_strength,
                  "annotation_count" => workspace.annotation_count,
                  "evidence_count" => workspace.evidence_count,
                  "verified_evidence_count" => workspace.verified_evidence_count
                }
              end

              def item_attributes(item)
                {
                  "id" => item.id,
                  "kind" => item.kind,
                  "title" => item.title,
                  "status" => item.status,
                  "position" => item.position,
                  "target_type" => item.target_type,
                  "target_id" => item.target_id,
                  "annotations" => item.annotations.ordered.map do |annotation|
                    annotation_attributes(annotation)
                  end,
                  "evidences" => item.evidences.ordered.map do |evidence|
                    evidence_attributes(evidence)
                  end
                }
              end

              def annotation_attributes(annotation)
                {
                  "id" => annotation.id,
                  "kind" => annotation.kind,
                  "title" => annotation.title,
                  "body" => annotation.body,
                  "confidence" => annotation.confidence,
                  "status" => annotation.status,
                  "position" => annotation.position,
                  "author_name" => annotation.author_name,
                  "reviewer_name" => annotation.reviewer_name,
                  "reviewed_at" => annotation.reviewed_at&.iso8601
                }
              end

              def evidence_attributes(evidence)
                {
                  "id" => evidence.id,
                  "title" => evidence.title,
                  "source_type" => evidence.source_type,
                  "source_url" => evidence.source_url,
                  "publisher" => evidence.publisher,
                  "author" => evidence.author,
                  "published_on" => evidence.published_on&.iso8601,
                  "accessed_on" => evidence.accessed_on&.iso8601,
                  "excerpt" => evidence.excerpt,
                  "notes" => evidence.notes,
                  "confidence" => evidence.confidence,
                  "verified" => evidence.verified?,
                  "verified_at" => evidence.verified_at&.iso8601,
                  "research_annotation_id" => evidence.research_annotation_id
                }
              end
            end
          end
        end
      end
    end
  end
end
