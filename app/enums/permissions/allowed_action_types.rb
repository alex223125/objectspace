module Permissions
  class AllowedActionTypes < ActiveEnum::Base
    value :id => 1, :name => :all_actions
    value :id => 2, :name => :modify
  end
end


