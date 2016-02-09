class Haiku < ActiveRecord::Base
  has_many :lines, inverse_of: :haiku
  accepts_nested_attributes_for :lines
  validates :lines, presence: true

  def self.complete
    joins(:lines).where( :lines => { :id => 3 } )
  end

  def self.in_progress
    self.all - self.complete
  end

  def lines_complete?
    lines.count = 3
  end

  def title
    lines.first.content
  end

  def lines_count_valid?
    lines.count < 3
  end
end
