module Permissions
  class SourceTypes < ActiveEnum::Base
    value :id => 1, :name => :created_automatically
    value :id => 2, :name => :created_by_user
    value :id => 3, :name => :created_by_organization
  end
end