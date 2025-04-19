module Improvable
  extend ActiveSupport::Concern

  included do
    has_many :improvements, :as => :improvable, class_name: "Improvements::Improvement"
  end
end