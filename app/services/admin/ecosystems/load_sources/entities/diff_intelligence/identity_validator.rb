# frozen_string_literal: true

module Ecosystems
  module LoadSources
    module Entity
      module DiffIntelligence
        class IdentityValidator
          Entry = Struct.new(
            :index,
            :object,
            :identity,
            :status,
            keyword_init: true
          )

          Result = Struct.new(
            :entries,
            :duplicates,
            :missing,
            keyword_init: true
          )

          def initialize(field:)
            @extractor = IdentityExtractor.new(field: field)
          end

          def call(objects)
            entries = []
            identity_indexes = Hash.new do |hash, key|
              hash[key] = []
            end
            missing = []

            Array(objects).each_with_index do |object, index|
              extracted = @extractor.call(object)

              entries << Entry.new(
                index: index,
                object: object,
                identity: extracted.identity,
                status: extracted.status
              )

              case extracted.status
              when :identified
                identity_indexes[extracted.identity] << index
              when :missing, :invalid
                missing << index
              end
            end

            duplicates =
              identity_indexes
                .select do |_identity, indexes|
                  indexes.length > 1
                end

            Result.new(
              entries: entries,
              duplicates: duplicates,
              missing: missing
            )
          end
        end
      end
    end
  end
end
