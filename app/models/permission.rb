class Permission < ApplicationRecord

  belongs_to :permissionable, polymorphic: true
  belongs_to :actorable, polymorphic: true

end