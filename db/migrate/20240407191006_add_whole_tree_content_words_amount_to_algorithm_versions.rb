class AddWholeTreeContentWordsAmountToAlgorithmVersions < ActiveRecord::Migration[7.0]
  def change
    add_column :algorithm_versions, :whole_tree_content_words_amount, :string
  end
end
