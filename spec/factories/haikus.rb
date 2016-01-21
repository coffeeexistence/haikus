FactoryGirl.define do
  params = { 0 => { :content => 'first line' } }
  factory :haiku do
    lines_attributes params
  end
end
