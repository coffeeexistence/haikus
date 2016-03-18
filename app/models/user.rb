class User < ActiveRecord::Base
  has_many :friendships
  has_many :friends, :through => :friendships
  has_many :inverse_friendships, :class_name => "Friendship", :foreign_key => "friend_id"
  has_many :inverse_friends, :through => :inverse_friendships, :source => :user
  has_many :haikus, -> { distinct }, :through => :lines
  has_many :lines

  attr_accessor :password, :current_password
  validates_confirmation_of :password
  validates_presence_of :password, on: :create
  validates_presence_of :email
  validates_presence_of :username, on: :create
  validates_uniqueness_of :email
  validate :current_password_is_correct, on: :update
  before_save :encrypt_password

  def self.authenticate(email, password)
    user = find_by_email(email)
    if user && user.valid_password?(password)
      user
    else
      nil
    end
  end

  def encrypt_password
    if password.present?
      self.password_salt = BCrypt::Engine.generate_salt
      self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
    end
  end

  def valid_password?(password)
    self.password_hash == BCrypt::Engine.hash_secret(password, self.password_salt)
  end

  def current_password_is_correct
    return if forgot_password_uuid
    if !valid_password?(current_password)
      errors.add(:current_password, "is incorrect.")
    end
  end

  def forgot_password
    update_attribute(:forgot_password_uuid, SecureRandom.uuid)
  end

  def remove_forgot_password_uuid
    update_attribute(:forgot_password_uuid, nil)
  end

  def friend_by_email(email)
    friend = self.class.find_or_create_by(email: email) do |u|
      u.password = u.password_confirmation = SecureRandom.base64(8)
      u.username = Word.random_words
    end
    self.friendships.find_or_create_by(friend: friend)
    friend
  end

  def has_friends?
    self.friends.any?
  end
end
