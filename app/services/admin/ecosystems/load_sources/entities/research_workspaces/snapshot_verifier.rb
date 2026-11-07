
# frozen_string_literal: true

require "digest"
require "json"

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module ResearchWorkspace
          class SnapshotVerifier
            def initialize(snapshot)
              @snapshot = snapshot
            end

            def valid?
              return false unless snapshot.data.is_a?(Hash)
              return false if snapshot.checksum.blank?

              expected = Digest::SHA256.hexdigest(
                JSON.generate(snapshot.data)
              )

              secure_compare(expected, snapshot.checksum)
            rescue JSON::GeneratorError, TypeError
              false
            end

            def verify!
              return true if valid?

              raise ArgumentError,
                    "Snapshot checksum verification failed"
            end

            private

            attr_reader :snapshot

            def secure_compare(left, right)
              return false unless left.bytesize == right.bytesize

              ActiveSupport::SecurityUtils.secure_compare(left, right)
            end
          end
        end
      end
    end
  end
end