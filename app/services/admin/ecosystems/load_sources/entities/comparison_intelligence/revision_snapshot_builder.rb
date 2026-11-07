
# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        class ComparisonIntelligence
          class RevisionSnapshotBuilder
            def initialize(adapter: EntitySnapshotAdapter.new)
              @adapter = adapter
            end

            def call(version:)
              return empty_snapshot unless version

              snapshot = adapter.call(version)

              {
                id: version.id.to_s,
                entity_id: read_attribute(version, :entity_id)&.to_s,
                version_number: read_attribute(version, :version_number),
                created_at: read_attribute(version, :created_at),
                updated_at: read_attribute(version, :updated_at),
                author_id: read_attribute(version, :user_id)&.to_s,
                snapshot: snapshot,
                fingerprint: ComparisonFingerprint.new.call(
                  changes: snapshot,
                  attributes: {
                    entity_id: read_attribute(version, :entity_id),
                    version_id: version.id
                  }
                )
              }
            end

            private

            attr_reader :adapter

            def read_attribute(record, name)
              return record.public_send(name) if record.respond_to?(name)

              nil
            end

            def empty_snapshot
              {
                id: nil,
                entity_id: nil,
                version_number: nil,
                created_at: nil,
                updated_at: nil,
                author_id: nil,
                snapshot: {},
                fingerprint: nil
              }
            end
          end
        end
      end
    end
  end
end