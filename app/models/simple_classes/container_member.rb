class SimpleClasses::ContainerMember < ApplicationRecord

  extend FriendlyId
  friendly_id :slug_candidates, use: [:slugged, :finders, :history]

  belongs_to :class_container
  belongs_to :memberable, polymorphic: true
  # has_one :simple_class, :through => :interface_group, class_name: "SimpleClasses::SimpleClass"

  # has_many :simple_classes, class_name: "SimpleClasses::SimpleClass", foreign_key: :framework_container_member_id

  def closest_simple_class
    self.class_container.simple_class || self.class_container.related_simple_class
  end

  private

  def slug_candidates
    [ :title,
      [:title, :id]
    ]
  end
end
