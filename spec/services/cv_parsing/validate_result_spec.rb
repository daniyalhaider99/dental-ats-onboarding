require "rails_helper"

RSpec.describe CvParsing::ValidateResult do
  let(:valid) do
    {
      "personal_details" => { "first_name" => "Anna", "last_name" => "de Vries", "email" => nil, "phone" => nil, "city" => nil, "country" => nil },
      "job_preferences" => { "current_job_title" => nil, "suggested_job_function" => nil },
      "employment" => { "big_status" => nil, "big_number" => nil, "years_of_experience" => nil },
      "educations" => [], "work_experiences" => [], "languages" => [],
      "skills" => [], "availability" => { "available_from" => nil, "notice_period" => nil },
      "summary" => nil, "low_confidence_fields" => []
    }
  end

  it "accepts a fully nullable payload" do
    expect(described_class.call(valid)).to be(true)
  end

  it "rejects an unknown job function enum value" do
    valid["job_preferences"]["suggested_job_function"] = "astronaut"
    expect { described_class.call(valid) }.to raise_error(CvParsing::InvalidResponseError)
  end

  it "rejects unexpected top-level properties" do
    valid["invented"] = "x"
    expect { described_class.call(valid) }.to raise_error(CvParsing::InvalidResponseError)
  end
end
