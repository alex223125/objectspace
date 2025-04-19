class Frameworks::FrameworkFolder < ApplicationRecord

  extend FriendlyId
  friendly_id :slug_candidates, use: [:slugged, :finders, :history]

  has_closure_tree


  belongs_to :framework, class_name: "Frameworks::Framework", optional: true
  belongs_to :creator, class_name: "User", foreign_key: :creator_id

  has_many :subfolders,
           class_name: "Frameworks::FrameworkFolder",
           foreign_key: "parent_id", dependent: :destroy
  accepts_nested_attributes_for :subfolders

  has_many :framework_members, class_name: "Frameworks::FrameworkMember"
  accepts_nested_attributes_for :framework_members


  belongs_to :related_framework, class_name: "Frameworks::Framework", foreign_key: :related_framework_id, optional: true

  def root_functional_type?
    self.functional_type == FrameworkFolders::FunctionalTypes[:root]
  end

  def closest_framework
    self.framework || self.related_framework
  end

  def content_present?
    true
    # self.interface_members.any? || self.groups.any?
  end

  def related_framework
    self.root.framework
  end

  private

  def slug_candidates
    [ :title,
      [:title, :uuid]
    ]
  end

end
