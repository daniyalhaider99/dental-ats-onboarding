FactoryBot.define do
  factory :candidate_document do
    candidate_profile
    document_type { :cv }
    original_filename { "cv.pdf" }
    content_type { "application/pdf" }
    file_size { 12_345 }
    parsing_status { :pending }

    after(:build) do |document|
      document.file.attach(
        io: StringIO.new("%PDF-1.4 test"),
        filename: document.original_filename,
        content_type: document.content_type
      )
    end

    trait :completed do
      parsing_status { :completed }
      parsed_at { Time.current }
    end

    trait :processing do
      parsing_status { :processing }
    end

    trait :failed do
      parsing_status { :failed }
      parsed_at { Time.current }
      parsing_error { "could not read" }
    end
  end
end
