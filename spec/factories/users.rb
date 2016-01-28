FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@factory.com" }
    password "password"

    factory :user_with_friend do
      after(:create) do |user, evaluator|
        create_list(:friendship, 3, user: user )
      end
    end
  end
end
