# frozen_string_literal: true

namespace :entities do
  desc "Reindex all encyclopedia entities in Searchkick"

  task reindex: :environment do
    entity_class =
      ::Ecosystems::LoadSources::Entity::Entity

    puts "Reindexing entities..."

    entity_class.reindex

    puts "Entity reindex complete."
  end
end