class Haiku < ActiveRecord::Base
  has_many :lines, inverse_of: :haiku
  accepts_nested_attributes_for :lines
  validates :lines, presence: true

  def title
    lines.first.content
  end

  def lines_count_valid?
    lines.count < 3
  end
end
