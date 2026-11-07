module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module ResearchCollections
          class SnapshotCreator
            def initialize(collection, label: nil, snapshot_type: "checkpoint")
              @collection = collection
              @label = label.presence || default_label
              @snapshot_type = snapshot_type
            end

            def call
              collection.snapshots.create!(
                snapshot_type: snapshot_type,
                label: label,
                payload: SnapshotBuilder.new(collection).call,
                captured_at: Time.current
              )
            end

            private

            attr_reader :collection, :label, :snapshot_type

            def default_label
              "Checkpoint #{Time.current.strftime('%Y-%m-%d %H:%M')}"
            end
          end
        end
      end
    end
  end
end
