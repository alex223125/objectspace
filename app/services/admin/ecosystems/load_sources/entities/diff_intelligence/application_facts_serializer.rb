# frozen_string_literal: true

module Ecosystems
  module LoadSources
    module Entity
      module DiffIntelligence
        class ApplicationFactsSerializer
          def self.call(application_facts)
            new.call(application_facts)
          end

          def call(application_facts)
            facts =
              if application_facts.respond_to?(:facts)
                application_facts.facts
              else
                Array(application_facts)
              end

            {
              "facts" => facts.map do |fact|
                serialize_fact(fact)
              end
            }
          end

          private

          def serialize_fact(fact)
            {
              "type" => fact.type.to_s,
              "path" => fact.path,
              "old_value" => fact.old_value,
              "new_value" => fact.new_value,
              "identity" => fact.identity,
              "old_index" => fact.old_index,
              "new_index" => fact.new_index,
              "metadata" => fact.metadata
            }
          end
        end
      end
    end
  end
end