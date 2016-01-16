class ApiKeySerializer < ActiveModel::Serializer
  attributes :id, :access_token, :created_at, :updated_at, :user_id
end
