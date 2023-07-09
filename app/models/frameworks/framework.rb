class Frameworks::Framework < ApplicationRecord

  extend FriendlyId
  friendly_id :slug_candidates, use: [:slugged, :finders, :history]

  extend Pagy::Searchkick
  searchkick callbacks: :async,
             text_middle: [:title, :description],
             word: [:list_of_tags, :ownerable_id]
  scope :search_import, -> { includes(:tags) }
  acts_as_taggable_on :tags

  belongs_to :ownerable, polymorphic: true

  belongs_to :folder, class_name: "Folder"

  has_many :interface_groups, class_name: "SimpleClasses::InterfaceGroup", dependent: :destroy
  accepts_nested_attributes_for :interface_groups

  has_many :class_containers, class_name: "SimpleClasses::ClassContainer", dependent: :destroy
  accepts_nested_attributes_for :class_containers

  # TODO: move to concern for framework and simple_Class
  def root_class_container
    self.class_containers.where(parent_id: nil).first
  end

  def root_interface_group
    self.interface_groups.where(parent_id: nil).first
  end

  def owner
    self.ownerable
  end

  def search_data
    {
      title: title,
      description: description,
      list_of_tags: tag_list,
      ownerable_id: ownerable_id
    }
  end

  private

  def slug_candidates
    [ :title,
      [:title, :id]
    ]
  end

end
