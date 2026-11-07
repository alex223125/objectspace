
# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module ResearchWorkspaces
          class ResearchProvenanceGraph
            def initialize(workspace)
              @workspace = workspace
            end

            def call
              nodes = []
              edges = []

              add_node(
                nodes,
                "workspace",
                workspace.id,
                title: workspace.title,
                status: workspace.status
              )

              items.each do |item|
                item_key = key("item", item.id)

                add_node(
                  nodes,
                  "item",
                  item.id,
                  title: value(item, :title),
                  kind: value(item, :kind),
                  status: value(item, :status)
                )

                edges << edge("contains", "workspace:#{workspace.id}", item_key)

                annotations_for(item).each do |annotation|
                  annotation_key = key("annotation", annotation.id)

                  add_node(
                    nodes,
                    "annotation",
                    annotation.id,
                    title: value(annotation, :title),
                    status: value(annotation, :status),
                    confidence: value(annotation, :confidence)
                  )

                  edges << edge("annotates", item_key, annotation_key)
                end

                evidences_for(item).each do |evidence|
                  evidence_key = key("evidence", evidence.id)

                  add_node(
                    nodes,
                    "evidence",
                    evidence.id,
                    title: value(evidence, :title),
                    source_name: value(evidence, :source_name),
                    source_url: safe_http_url(value(evidence, :source_url)),
                    status: value(evidence, :status),
                    confidence: value(evidence, :confidence),
                    verified: verified?(evidence)
                  )

                  edges << edge("supported_by", item_key, evidence_key)

                  annotation_id = value(evidence, :research_annotation_id)

                  if annotation_id.present?
                    edges << edge(
                      "supports_annotation",
                      "annotation:#{annotation_id}",
                      evidence_key
                    )
                  end
                end
              end

              {
                workspace_id: workspace.id,
                nodes: nodes,
                edges: edges,
                summary: {
                  nodes: nodes.size,
                  edges: edges.size,
                  items: items.size
                },
                generated_at: Time.current.iso8601
              }
            end

            private

            attr_reader :workspace

            def items
              @items ||= workspace.items
                                  .includes(:annotations, :evidences)
                                  .order(:position, :created_at)
                                  .to_a
            rescue ActiveRecord::ActiveRecordError
              []
            end

            def annotations_for(item)
              item.respond_to?(:annotations) ? item.annotations.to_a : []
            rescue ActiveRecord::ActiveRecordError
              []
            end

            def evidences_for(item)
              item.respond_to?(:evidences) ? item.evidences.to_a : []
            rescue ActiveRecord::ActiveRecordError
              []
            end

            def add_node(nodes, type, id, attributes = {})
              nodes << {
                id: key(type, id),
                type: type
              }.merge(attributes)
            end

            def edge(type, source, target)
              {
                id: "#{type}:#{source}:#{target}",
                type: type,
                source: source,
                target: target
              }
            end

            def key(type, id)
              "#{type}:#{id}"
            end

            def value(record, attribute)
              return unless record.respond_to?(attribute)

              record.public_send(attribute)
            end

            def verified?(record)
              return record.verified? if record.respond_to?(:verified?)

              return record.verified == true if record.respond_to?(:verified)

              return true if record.respond_to?(:verified_at) &&
                record.verified_at.present?

              value(record, :status).to_s == "verified"
            end

            def safe_http_url(raw_url)
              return if raw_url.blank?

              uri = URI.parse(raw_url.to_s)
              return unless %w[http https].include?(uri.scheme)
              return if uri.host.blank?
              return if uri.userinfo.present?

              uri.to_s
            rescue URI::InvalidURIError
              nil
            end
          end
        end
      end
    end
  end
end