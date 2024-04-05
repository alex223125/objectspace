class SimpleClasses::ContainerMember < ApplicationRecord

  extend FriendlyId
  friendly_id :slug_candidates, use: [:slugged, :finders, :history]

  belongs_to :class_container
  belongs_to :memberable, polymorphic: true
  has_one :simple_class, :through => :interface_group, class_name: "SimpleClasses::SimpleClass"

  private

  def slug_candidates
    [ :title,
      [:title, :id]
    ]
  end
end
