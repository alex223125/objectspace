class SimpleObjects::SimpleObject < ApplicationRecord

  has_many :folders, class_name: "SimpleObjects::Folder", dependent: :destroy

end
