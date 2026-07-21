FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "candidate#{n}@example.nl" }
  end
end
