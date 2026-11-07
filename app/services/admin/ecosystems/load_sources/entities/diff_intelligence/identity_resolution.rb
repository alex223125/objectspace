# frozen_string_literal: true

module Admin
module Ecosystems
  module LoadSources
    module Entities
      module DiffIntelligence
        IdentityMatch =
          Struct.new(
            :identity,
            :classification,
            :old_index,
            :new_index,
            :old_item,
            :new_item,
            keyword_init: true
          )

        IdentityWarning =
          Struct.new(
            :code,
            :side,
            :identity,
            :indexes,
            :reason,
            keyword_init: true
          )

        class IdentityResolutionResult
          attr_reader(
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
            matches:,
            warnings:,
            missing_identity_old:,
            missing_identity_new:,
            duplicates:,
            ambiguous:,
            unmatched_old:,
            unmatched_new:
          )
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
              %i[moved unchanged changed].include?(match.classification)
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

        class IdentityResolution
          class << self
            def call(old_array:, new_array:, identity_field:)
              new(
                identity_field: identity_field
              ).call(
                old_array,
                new_array
              )
            end
          end

          def initialize(identity_field:)
            @identity_field = identity_field.to_s
          end

          def call(old_array, new_array)
            old_items = Array(old_array)
            new_items = Array(new_array)

            old_index =
              index_items(old_items)

            new_index =
              index_items(new_items)

            warnings = []
            missing_old = old_index[:missing]
            missing_new = new_index[:missing]

            missing_old.each do |index|
              warnings << IdentityWarning.new(
                code: :missing_identity,
                side: :old,
                identity: nil,
                indexes: [index],
                reason: "Missing identity field #{@identity_field} at old index #{index}"
              )
            end

            missing_new.each do |index|
              warnings << IdentityWarning.new(
                code: :missing_identity,
                side: :new,
                identity: nil,
                indexes: [index],
                reason: "Missing identity field #{@identity_field} at new index #{index}"
              )
            end

            duplicate_old =
              duplicates(old_index[:by_identity])

            duplicate_new =
              duplicates(new_index[:by_identity])

            duplicate_old.each do |identity, indexes|
              warnings << IdentityWarning.new(
                code: :duplicate_identity,
                side: :old,
                identity: identity,
                indexes: indexes,
                reason: "Identity #{identity.inspect} appears multiple times on the old side"
              )
            end

            duplicate_new.each do |identity, indexes|
              warnings << IdentityWarning.new(
                code: :duplicate_identity,
                side: :new,
                identity: identity,
                indexes: indexes,
                reason: "Identity #{identity.inspect} appears multiple times on the new side"
              )
            end

            ambiguous =
              (
                duplicate_old.keys |
                  duplicate_new.keys
              ).sort_by(&:to_s)

            ambiguous.each do |identity|
              old_indexes =
                duplicate_old.fetch(identity, [])

              new_indexes =
                duplicate_new.fetch(identity, [])

              warnings << IdentityWarning.new(
                code: :ambiguous_identity,
                side: ambiguity_side(old_indexes, new_indexes),
                identity: identity,
                indexes: {
                  old: old_indexes,
                  new: new_indexes
                },
                reason:
                  "Identity #{identity.inspect} cannot be matched deterministically because it is duplicated"
              )
            end

            matches = []
            unmatched_old = []
            unmatched_new = []

            identities =
              (
                old_index[:by_identity].keys |
                  new_index[:by_identity].keys
              ).sort_by(&:to_s)

            identities.each do |identity|
              old_indexes =
                old_index[:by_identity][identity]

              new_indexes =
                new_index[:by_identity][identity]

              next if old_indexes&.length.to_i > 1
              next if new_indexes&.length.to_i > 1

              old_position = old_indexes&.first
              new_position = new_indexes&.first

              if old_position && new_position
                old_item = old_items[old_position]
                new_item = new_items[new_position]

                classification =
                  if old_position == new_position
                    :unchanged
                  else
                    :moved
                  end

                matches << IdentityMatch.new(
                  identity: identity,
                  classification: classification,
                  old_index: old_position,
                  new_index: new_position,
                  old_item: old_item,
                  new_item: new_item
                )
              elsif new_position
                matches << IdentityMatch.new(
                  identity: identity,
                  classification: :added,
                  old_index: nil,
                  new_index: new_position,
                  old_item: nil,
                  new_item: new_items[new_position]
                )
              elsif old_position
                matches << IdentityMatch.new(
                  identity: identity,
                  classification: :removed,
                  old_index: old_position,
                  new_index: nil,
                  old_item: old_items[old_position],
                  new_item: nil
                )
              end
            end

            duplicate_old.each_value do |indexes|
              indexes.each do |index|
                unmatched_old << old_items[index]
              end
            end

            duplicate_new.each_value do |indexes|
              indexes.each do |index|
                unmatched_new << new_items[index]
              end
            end

            missing_old.each do |index|
              unmatched_old << old_items[index]
            end

            missing_new.each do |index|
              unmatched_new << new_items[index]
            end

            IdentityResolutionResult.new(
              matches: matches.sort_by do |match|
                [
                  match.new_index || Float::INFINITY,
                  match.old_index || Float::INFINITY,
                  match.identity.to_s
                ]
              end,
              warnings: warnings,
              missing_identity_old: missing_old,
              missing_identity_new: missing_new,
              duplicates: {
                old: duplicate_old,
                new: duplicate_new
              },
              ambiguous: ambiguous.each_with_object({}) do |identity, result|
                result[identity] = true
              end,
              unmatched_old: unmatched_old,
              unmatched_new: unmatched_new
            )
          end

          private

          def index_items(items)
            by_identity = Hash.new { |hash, key| hash[key] = [] }
            missing = []

            items.each_with_index do |item, index|
              identity =
                item.is_a?(Hash) ?
                  item[@identity_field] || item[@identity_field.to_sym] :
                  nil

              if identity.nil? || identity.to_s.empty?
                missing << index
              else
                by_identity[identity.to_s] << index
              end
            end

            {
              by_identity: by_identity,
              missing: missing
            }
          end

          def duplicates(index)
            index.each_with_object({}) do |(identity, indexes), result|
              result[identity] = indexes if indexes.length > 1
            end
          end

          def ambiguity_side(old_indexes, new_indexes)
            if old_indexes.any? && new_indexes.any?
              :both
            elsif old_indexes.any?
              :old
            else
              :new
            end
          end
        end

        class IdentityResolver
          def initialize(identity_field:)
            @identity_field = identity_field
          end

          def call(old_array, new_array)
            IdentityResolution.call(
              old_array: old_array,
              new_array: new_array,
              identity_field: @identity_field
            )
          end
        end
      end
    end
  end
end
end
