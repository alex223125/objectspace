class UsageExample < ApplicationRecord

  belongs_to :usage_exampable, polymorphic: true

end
