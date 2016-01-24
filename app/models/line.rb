class Line < ActiveRecord::Base
  belongs_to :user
  belongs_to :haiku
  validates :haiku, presence: true
  validates :user, presence: true
  validates :content, presence: true
end
