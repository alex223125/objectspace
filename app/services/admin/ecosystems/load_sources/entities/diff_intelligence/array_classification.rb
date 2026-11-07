# frozen_string_literal: true

module Ecosystems
  module LoadSources
    module Entity
      module DiffIntelligence
        class ArrayClassification
          attr_reader :path,
                      :identity_key,
                      :matches,
                      :added_indexes,
                      :removed_indexes,
                      :issues

          def initialize(result:)
            @path = result.path
            @identity_key = result.identity_key
            @matches = result.matches
            @added_indexes = result.added_indexes
            @removed_indexes = result.removed_indexes
            @issues = result.issues
          end

          def moved
            matches.select(&:moved?)
          end

          def unchanged_position
            matches.reject(&:moved?)
          end

          def added
            added_indexes
          end

          def removed
            removed_indexes
          end

          def ambiguous?
            issues.any?(&:ambiguous_identity?)
          end

          def duplicate?
            issues.any?(&:duplicate_identity?)
          end

          def missing?
            issues.any?(&:missing_identity?)
          end

          def safe_to_compare?
            issues.none?(&:error?)
          end

          def to_h
            {
              path: path,
              identity_key: identity_key,
              moved: moved.map(&:to_h),
              unchanged_position: unchanged_position.map(&:to_h),
              added: added,
              removed: removed,
              issues: issues.map(&:to_h),
              safe_to_compare: safe_to_compare?
            }
          end
        end
      end
    end
  end
end