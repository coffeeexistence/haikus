class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :password_hash, :password_salt
end
