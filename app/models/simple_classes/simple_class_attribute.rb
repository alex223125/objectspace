class SimpleClasses::SimpleClassAttribute < ApplicationRecord

  belongs_to :simple_class

  belongs_to :article, class_name: "Articles::Article", optional: true


  has_many :actions_simple_class_attributes, dependent: :destroy
  has_many :actions, through: :actions_simple_class_attributes, class_name: "SimpleClasses::InterfaceMember"
  accepts_nested_attributes_for :actions, allow_destroy: true

  def class_key
    "attribute"
  end

  def uniq_key
    class_key + self.uuid
  end

end
