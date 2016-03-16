class Haiku < ActiveRecord::Base
  has_many :lines, inverse_of: :haiku
  accepts_nested_attributes_for :lines
  validates :lines, presence: true

  def self.complete
    where(id: complete_ids)
  end

  def self.in_progress
    where.not(id: complete_ids)
  end

  def self.complete_ids
    Line.group(:haiku_id).count.select { |key, value| value == 3 }.keys
  end

  def title
    lines.first.content
  end

  def lines_count_valid?
    lines.count < 3
  end

  def wrote_with_friend?
    lines.first.user_id != lines.second.user_id || lines.first.user_id != lines.third.user_id
  end

  def wrote_with_friends?
    lines.first.user_id != lines.second.user_id && lines.first.user_id != lines.third.user_id
  end

  def friend
    if lines.third.user_id == lines.first.user_id
      User.where(id: lines.second.user_id).first
    elsif
      User.where(id: lines.first.user_id).first
    end
  end

  def friends
    friends = []
    friends << User.where(id: lines.first.user_id).first
    friends << User.where(id: lines.second.user_id).first
    return friends
  end
end
