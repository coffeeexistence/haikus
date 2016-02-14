class Word < ActiveRecord::Base
  def self.random_words
    arr = []
    self.find_each do |word|
      arr << word.word
    end
    arr.sample(2).join
  end
end
