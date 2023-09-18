class Articles::Article < ApplicationRecord

  extend Pagy::Searchkick

  acts_as_taggable_on :tags

  searchkick callbacks: :async,
             text_middle: [:title, :source_page_description],
             word: [:list_of_tags, :ownerable_id]
  scope :search_import, -> { includes(:tags) }



  belongs_to :folder, class_name: "Folder", optional: true
  belongs_to :repository, class_name: "Repository", optional: true
  # TODO: validate that its in repository or in folder, not in both

  belongs_to :ownerable, polymorphic: true

  has_many :article_versions, class_name: "Articles::ArticleVersion", dependent: :destroy
  accepts_nested_attributes_for :article_versions

  belongs_to :simple_class_attributes, class_name: "SimpleClasses::SimpleClassAttribute", optional: true

  validates :title, presence: true, allow_blank: false

  belongs_to :default_version, foreign_key: "default_version_id", class_name: "Articles::ArticleVersion"

  def search_data
    {
      title: title,
      source_page_description: source_page_description,
      list_of_tags: tag_list,
      ownerable_id: ownerable_id,
      folder_id: folder_id,
      repository_id: repository_id
    }
  end

  # def search_data
  #   {
  #     ##XXXXXXXX  why cant i use this XXXXXXXXX
  #     ###active: true,
  #     name: name, index: "not_analyzed",
  #     capacity: capacity.to_i,
  #     slug: slug,
  #     ### i need to add active to so that i can use where(:active => true) in search
  #     active: active,
  #     event_type_name: event_types.map(&:name),
  #     facility_name: facilities.map(&:name),
  #     ratings: ratings.map(&:stars),
  #     location: [self.address.latitude, self.address.longitude],
  #     picture_url: pictures.select{|p| p == pictures.last}.map do |i|{
  #
  #       original:  i.original_url
  #
  #     }
  #     end
  #   }
  # end


end
