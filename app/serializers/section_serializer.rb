class SectionSerializer < ActiveModel::Serializer
  attributes :id
  has_one :sectionable
end
