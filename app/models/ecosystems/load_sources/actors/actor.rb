# class Ecosystems::LoadSources::Actors::Actor < ApplicationRecord
#   validates :name, presence: true
#   validates :slug, presence: true, uniqueness: true
#   validates :status, presence: true
# end
module Ecosystems
  module LoadSources
    module Actors
      class Actor < ApplicationRecord
        self.table_name = "ecosystems_load_sources_actors_actors"

        extend Pagy::Searchkick

        STATUSES = %w[draft published archived].freeze

        searchkick callbacks: :async,
                   text_middle: [:name, :description],
                   word: [:name, :description],
                   word_start: [:name, :description],
                   word_end: [:name, :description]

        validates :name, presence: true
        validates :slug, presence: true, uniqueness: true
        validates :status, presence: true, inclusion: { in: STATUSES }

        scope :search_import, -> { all }

        private

        def search_data
          {
            name: name,
            description: description,
            slug: slug,
            status: status
          }
        end
      end
    end
  end
end