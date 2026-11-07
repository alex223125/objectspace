# frozen_string_literal: true

module Ecosystems
  module LoadSources
    module Entity
      module DiffIntelligence
        class ResolveArrayIdentities
          def self.call(
            old_items:,
            new_items:,
            identity_key:,
            path:
          )
            resolution =
              IdentityResolution.call(
                old_array: old_items,
                new_array: new_items,
                identity_field: identity_key
              )

            IdentityResolutionResultWithPath.new(
              resolution,
              path: path,
              identity_key: identity_key
            )
          end

          class IdentityResolutionResultWithPath
            def initialize(result, path:, identity_key:)
              @result = result
              @path = path.to_s
              @identity_key = identity_key.to_s
            end

            attr_reader :path, :identity_key

            def matches
              @result.matches
            end

            def warnings
              @result.warnings
            end

            def missing_identity_old
              @result.missing_identity_old
            end

            def missing_identity_new
              @result.missing_identity_new
            end

            def duplicates
              combined =
                {}

              @result.duplicates.fetch(:old, {}).each do |identity, indexes|
                combined[identity] = {
                  old: indexes
                }
              end

              @result.duplicates.fetch(:new, {}).each do |identity, indexes|
                combined[identity] ||= {}
                combined[identity][:new] = indexes
              end

              combined
            end

            def ambiguous
              @result.ambiguous
            end

            def unmatched_old
              @result.unmatched_old
            end

            def unmatched_new
              @result.unmatched_new
            end

            def safe?
              @result.safe?
            end

            def matched
              @result.matched
            end

            def added
              @result.added
            end

            def removed
              @result.removed
            end
          end
        end

        IdentityResolutionResult =
          ResolveArrayIdentities::IdentityResolutionResultWithPath
      end
    end
  end
end