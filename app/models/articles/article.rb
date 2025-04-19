class Articles::Article < ApplicationRecord
  include Sourceable
  include Improvable

  extend FriendlyId
  friendly_id :slug_candidates, use: [:slugged, :finders, :history]

  extend Pagy::Searchkick
  searchkick callbacks: :async,
             text_start: [:title, :source_page_description],
             text_middle: [:title, :source_page_description],
             text_end: [:title, :source_page_description],
             word: [:list_of_tags, :ownerable_id]
  scope :search_import, -> { includes(:tags) }
  acts_as_taggable_on :tags

  ###
  # TODO: validate that its in repository or in folder, not in both and not without at leas one of them
  belongs_to :folder, class_name: "Folder", optional: true
  belongs_to :repository, class_name: "Repository", optional: true

  has_many :container_members, as: :memberable, class_name: "SimpleClasses::ContainerMember"
  has_many :interface_members, as: :memberable, class_name: "SimpleClasses::InterfaceMember"
  ###

  belongs_to :ownerable, polymorphic: true
  belongs_to :creator, class_name: "User", foreign_key: :creator_id

  belongs_to :simple_class_attributes, class_name: "SimpleClasses::SimpleClassAttribute", optional: true
  belongs_to :default_version, foreign_key: "default_version_id", class_name: "Articles::ArticleVersion"

  has_many :article_versions, class_name: "Articles::ArticleVersion", dependent: :destroy
  accepts_nested_attributes_for :article_versions

  has_many :articles_simple_class_attributes, dependent: :destroy, class_name: "SimpleClasses::ArticlesSimpleClassAttribute"
  has_many :simple_class_attributes, through: :articles_simple_class_attributes, class_name: "SimpleClasses::SimpleClassAttribute"

  has_many :link_attachments, as: :linkable, class_name: "CheatSheets::LinkAttachment"

  has_many :sections, as: :sectionable, class_name: "CheatSheetGroups::Section"

  has_many :permissions, as: :permissionable, class_name: "Permission"

  validates :title, presence: true, allow_blank: false

  def class_key
    "article"
  end

  def uniq_key
    class_key + self.uuid
  end

  def owner
    self.ownerable
  end

  private

  # doc: mapping for searchkick
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

  def slug_candidates
    [ :title,
      [:title, :uuid]
    ]
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
