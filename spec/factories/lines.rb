FactoryGirl.define do
  factory :line do
    haiku
    content "MyString"

    after(:build) do |line|
      line.user = FactoryGirl.create(:user)
    end
  end

end
