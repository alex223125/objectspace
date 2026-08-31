module Admin
  module Ecosystems
    module LoadSources
      module EntityTemplates
        class EntityTemplateResolver
          def initialize(entity_type:, ecosystem: nil, activity: nil, load_source: nil)
            @entity_type = entity_type
            @ecosystem = ecosystem
            @activity = activity
            @load_source = load_source
          end

          def call
            find_configuration&.entity_template ||
              default_template
          end

          private

          attr_reader :entity_type,
                      :ecosystem,
                      :activity,
                      :load_source

          def find_configuration
            contexts = [
              ["LoadSource", load_source],
              ["Activity", activity],
              ["Ecosystem", ecosystem]
            ]

            contexts.each do |context_type, context|
              next unless context

              configuration =
                EntityTemplateConfiguration
                  .active
                  .where(
                    entity_type: entity_type,
                    context_type: context_type,
                    context_id: context.id
                  )
                  .order(priority: :desc)
                  .first

              return configuration if configuration
            end

            nil
          end

          def default_template
            EntityTemplate
              .where(
                entity_type: entity_type,
                status: :active
              )
              .order(:id)
              .first
          end
        end
      end
    end
  end
end
