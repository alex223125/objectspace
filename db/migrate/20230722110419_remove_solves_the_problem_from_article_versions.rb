class RemoveSolvesTheProblemFromArticleVersions < ActiveRecord::Migration[7.0]
  def change
    remove_column :article_versions, :solves_the_problem, :text
  end
end
