class SimpleClasses::InterfaceMember < ApplicationRecord

  belongs_to :interface_group
  belongs_to :memberable, polymorphic: true

end
