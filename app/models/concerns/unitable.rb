module Unitable
  extend ActiveSupport::Concern

  def owner
    self.whole_unit.ownerable
  end

end