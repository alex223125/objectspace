class AddPriorityToEcosystemsLoadSourcesEntityTemplateConfigurations < ActiveRecord::Migration[7.0]
  def change
    add_column :ecosystems_load_sources_entity_template_configurations, :priority, :integer
  end
end
