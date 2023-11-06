class SimpleClasses::ArticlesSimpleClassAttribute < ApplicationRecord
  belongs_to :article, class_name: "Articles::Article"
  belongs_to :simple_class_attribute, class_name: "SimpleClasses::SimpleClassAttribute"
end
