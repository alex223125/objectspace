class SimpleClasses::ContainerMember < ApplicationRecord

  belongs_to :class_container
  belongs_to :memberable, polymorphic: true

end
