FactoryGirl.define do
  params = { 0 => { :content => 'first line' } }
  factory :haiku do
    lines_attributes params

    factory :haiku_with_lines do
      after(:create) do |haiku, evaluator|
        create_list(:line, 2, haiku: haiku)
      end
    end
  end
end
