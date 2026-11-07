# frozen_string_literal: true

module Ecosystems
  module LoadSources
    module Entity
      module DiffIntelligence
        class IdentityResolutionResult
          attr_reader(
            :path,
            :identity_key,
            :matches,
            :warnings,
            :missing_identity_old,
            :missing_identity_new,
            :duplicates,
            :ambiguous,
            :unmatched_old,
            :unmatched_new
          )

          def initialize(
            path:,
            identity_key:,
            matches:,
            warnings:,
            missing_identity_old:,
            missing_identity_new:,
            duplicates:,
            ambiguous:,
            unmatched_old:,
            unmatched_new:
          )
            @path = path.to_s
            @identity_key = identity_key.to_s
            @matches = matches
            @warnings = warnings
            @missing_identity_old = missing_identity_old
            @missing_identity_new = missing_identity_new
            @duplicates = duplicates
            @ambiguous = ambiguous
            @unmatched_old = unmatched_old
            @unmatched_new = unmatched_new
          end

          def safe?
            warnings.empty?
          end

          def matched
            matches.select do |match|
              %i[unchanged moved changed].include?(match.classification)
            end
          end

          def added
            matches.select do |match|
              match.classification == :added
            end
          end

          def removed
            matches.select do |match|
              match.classification == :removed
            end
          end
        end

        class ResolveArrayIdentities
          def self.call(
            old_items:,
            new_items:,
            identity_key:,
            path:
          )
            result =
              IdentityResolution.call(
                old_array: old_items,
                new_array: new_items,
                identity_field: identity_key
              )

            IdentityResolutionResult.new(
              path: path,
              identity_key: identity_key,
              matches: result.matches,
              warnings: result.warnings,
              missing_identity_old: result.missing_identity_old,
              missing_identity_new: result.missing_identity_new,
              duplicates: result.duplicates,
              ambiguous: result.ambiguous,
              unmatched_old: result.unmatched_old,
              unmatched_new: result.unmatched_new
            )
          end
        end
      end
    end
  end
end