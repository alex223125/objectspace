module Repositories
  class FunctionalTypes < ActiveEnum::Base
    value :id => 1, :name => :default_user_technologies_repository
    value :id => 2, :name => :regular
  end
end