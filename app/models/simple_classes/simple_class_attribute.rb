class SimpleClasses::SimpleClassAttribute < ApplicationRecord

  belongs_to :simple_class

  has_many :actions_simple_class_attributes, dependent: :destroy
  has_many :actions, through: :actions_simple_class_attributes, class_name: "SimpleClasses::InterfaceMember"
  # accepts_nested_attributes_for :actions, allow_destroy: true
  accepts_nested_attributes_for :actions


  has_many :articles_simple_class_attributes, dependent: :destroy, class_name: "SimpleClasses::ArticlesSimpleClassAttribute"
  has_many :articles, through: :articles_simple_class_attributes, class_name: "Articles::Article"
  # accepts_nested_attributes_for :articles, allow_destroy: true
  accepts_nested_attributes_for :articles_simple_class_attributes, allow_destroy: true

  def class_key
    "attribute"
  end

  def uniq_key
    class_key + self.uuid
  end

end
