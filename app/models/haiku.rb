class Haiku < ActiveRecord::Base
  has_many :lines, inverse_of: :haiku
  accepts_nested_attributes_for :lines
  validates :lines, presence: true

  #scope :complete, -> { includes(:lines).where( self.lines.count = 3) }

  #scope :in_progress, -> {includes(:lines).where( self.lines.size < 3)}

  def self.complete
    joins(:lines).where( :lines => { :id => 3 } )
  end

  def self.in_progress
    joins(:lines).select("COUNT(lines) < 3")
  end


  def title
    lines.first.content
  end

  def lines_count_valid?
    lines.count < 3
  end
end
