class SimpleObjects::Folder < ApplicationRecord

  belongs_to :simple_object, class_name: "SimpleObjects::SimpleObject"

end
