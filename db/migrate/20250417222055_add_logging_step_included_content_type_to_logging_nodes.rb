class AddLoggingStepIncludedContentTypeToLoggingNodes < ActiveRecord::Migration[7.0]
  def change
    add_column :logging_nodes, :logging_step_included_content_type, :integer
  end
end

