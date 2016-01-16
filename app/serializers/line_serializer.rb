class LineSerializer < ActiveModel::Serializer
  attributes :id, :haiku_id, :content
end
