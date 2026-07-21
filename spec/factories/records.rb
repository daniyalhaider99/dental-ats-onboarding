FactoryBot.define do
  factory :education do
    candidate_profile
    study { "Tandheelkunde" }
    institution { "Universiteit van Amsterdam" }
    level { :master }
  end

  factory :work_experience do
    candidate_profile
    job_title { "Tandarts" }
    company_name { "Tandartspraktijk Centrum" }
  end

  factory :skill_group do
    sequence(:slug) { |n| "group_#{n}" }
    sequence(:name) { |n| "Group #{n}" }
  end

  factory :skill do
    skill_group
    sequence(:slug) { |n| "skill_#{n}" }
    sequence(:name) { |n| "Skill #{n}" }
  end

  factory :job_function do
    skill_group
    sequence(:slug) { |n| "function_#{n}" }
    sequence(:name) { |n| "Function #{n}" }
  end

  factory :language do
    sequence(:slug) { |n| "language_#{n}" }
    sequence(:name) { |n| "Language #{n}" }
  end
end
