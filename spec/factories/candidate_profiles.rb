FactoryBot.define do
  factory :candidate_profile do
    status { :draft }
    consented_at { Time.current }

    trait :completed do
      status { :completed }
    end

    trait :prefilled do
      first_name { "Anna" }
      last_name { "de Vries" }
      email { "anna@example.nl" }
      phone { "+31612345678" }
      city { "Amsterdam" }
      country { "Netherlands" }
      years_of_experience { 7 }
      available_from { Date.new(2026, 9, 1) }
      extraction_metadata do
        { "first_name" => { "source" => "cv" }, "phone" => { "source" => "cv", "needs_review" => true } }
      end
    end
  end
end
