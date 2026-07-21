require "rails_helper"

RSpec.describe CvParsing::MapResult do
  before { seed_reference_data }

  let(:parsed) do
    {
      "personal_details" => { "first_name" => "Anna", "last_name" => "de Vries", "email" => "Anna@Example.NL", "phone" => "+31612345678", "city" => "Amsterdam", "country" => "Netherlands" },
      "job_preferences" => { "current_job_title" => "Tandarts", "suggested_job_function" => "general_dentist" },
      "employment" => { "big_status" => "registered", "big_number" => "123", "years_of_experience" => 7 },
      "educations" => [ { "study" => "Tandheelkunde", "level" => "master", "start_date" => "2010-09-01", "end_date" => "2016-06-30" } ],
      "work_experiences" => [ { "job_title" => "Tandarts", "company_name" => "Centrum", "current_job" => true, "end_date" => "2020-01-01" } ],
      "languages" => [ { "name" => "Dutch", "proficiency" => "native" } ],
      "skills" => [ "Endodontics" ],
      "availability" => { "available_from" => "2026-09-01", "notice_period" => "1 month" },
      "summary" => "Experienced.",
      "low_confidence_fields" => [ "personal_details.phone" ]
    }
  end

  it "creates no database rows" do
    expect { described_class.call(parsed) }.not_to change(CandidateProfile, :count)
  end

  it "downcases the email and resolves the job function" do
    mapped = described_class.call(parsed)
    expect(mapped.profile_attributes[:email]).to eq("anna@example.nl")
    expect(mapped.job_function.slug).to eq("general_dentist")
  end

  it "marks extracted fields and flags low-confidence ones" do
    meta = described_class.call(parsed).extraction_metadata
    expect(meta["first_name"]).to eq({ "source" => "cv" })
    expect(meta["phone"]).to eq({ "source" => "cv", "needs_review" => true })
  end

  it "drops the end date from a current job" do
    mapped = described_class.call(parsed)
    expect(mapped.work_experiences.first).to include(current_job: true, end_date: nil)
  end
end
