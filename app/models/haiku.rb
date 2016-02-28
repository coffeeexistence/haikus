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
end
