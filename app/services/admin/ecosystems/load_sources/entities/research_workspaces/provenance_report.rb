
# frozen_string_literal: true

module Admin
  module ResearchWorkspaces
    class ProvenanceReport
      def initialize(workspace)
        @workspace = workspace
      end

      def call
        items = association_records(@workspace, :items) || []

        payloads = items.map { |item| item_payload(item) }

        {
          workspace: {
            id: @workspace.id,
            title: value(@workspace, :title),
            status: value(@workspace, :status)
          },
          items: payloads,
          totals: {
            items: payloads.size,
            annotations: payloads.sum { |item| item[:annotations].size },
            evidence: payloads.sum { |item| item[:evidence].size }
          }
        }
      end

      private

      def item_payload(item)
        annotations = association_records(item, :annotations) ||
          association_records(item, :research_annotations) || []

        evidence = association_records(item, :evidences) ||
          association_records(item, :research_evidences) || []

        {
          id: item.id,
          title: value(item, :title),
          kind: value(item, :kind),
          status: value(item, :status),
          target: {
            type: value(item, :target_type),
            id: value(item, :target_id)
          },
          annotations: annotations.map do |annotation|
            {
              id: annotation.id,
              title: value(annotation, :title),
              type: value(annotation, :annotation_type),
              status: value(annotation, :status),
              confidence: value(annotation, :confidence)
            }
          end,
          evidence: evidence.map do |record|
            {
              id: record.id,
              title: value(record, :title),
              type: value(record, :evidence_type),
              status: value(record, :status),
              source_name: value(record, :source_name),
              source_url: value(record, :source_url),
              confidence: value(record, :confidence),
              verified: verified?(record)
            }
          end
        }
      end

      def association_records(record, name)
        return nil unless record.class.reflect_on_association(name)

        record.public_send(name).to_a
      rescue NoMethodError
        nil
      end

      def value(record, attribute)
        record.public_send(attribute) if record.respond_to?(attribute)
      end

      def verified?(record)
        if record.respond_to?(:verified?)
          !!record.verified?
        elsif record.respond_to?(:verified)
          !!record.verified
        else
          value(record, :status).to_s == "verified"
        end
      end
    end
  end
end