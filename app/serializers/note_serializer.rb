class NoteSerializer < ActiveModel::Serializer
  attributes :id, :title, :description
end
