require "rails_helper"

RSpec.describe CvParsing::SaveResult do
  before { seed_reference_data }

  let(:profile) { create(:candidate_profile) }
  let(:parsed) do
    {
      "personal_details" => { "first_name" => "Anna", "last_name" => "de Vries", "email" => "anna@example.nl", "phone" => "+31612345678", "city" => "Amsterdam", "country" => "NL" },
      "job_preferences" => { "current_job_title" => "Tandarts", "suggested_job_function" => "general_dentist" },
      "employment" => { "big_status" => "registered", "big_number" => "123", "years_of_experience" => 7 },
      "educations" => [ { "study" => "Tandheelkunde", "level" => "master" } ],
      "work_experiences" => [ { "job_title" => "Tandarts", "company_name" => "Centrum", "current_job" => true } ],
      "languages" => [ { "name" => "Dutch", "proficiency" => "native" }, { "name" => "Klingon", "proficiency" => nil } ],
      "skills" => [ "Endodontics", "endodontics", "Botox" ],
      "availability" => { "available_from" => nil, "notice_period" => nil },
      "summary" => nil, "low_confidence_fields" => []
    }
  end

  def save!
    described_class.call(profile: profile, mapped: CvParsing::MapResult.call(parsed))
    profile.reload
  end

  it "persists the profile, education and work experience" do
    save!
    expect(profile.first_name).to eq("Anna")
    expect(profile.educations.count).to eq(1)
    expect(profile.work_experiences.count).to eq(1)
  end

  it "matches known languages and drops unknown ones" do
    save!
    expect(profile.languages.pluck(:name)).to contain_exactly("Dutch")
  end

  it "matches skills to the function group, dedupes, and keeps unknowns as suggestions" do
    save!
    expect(profile.candidate_skills.matched.map { |s| s.skill.name }).to contain_exactly("Endodontics")
    expect(profile.candidate_skills.suggested.map(&:free_text_suggestion)).to contain_exactly("Botox")
  end

  it "is idempotent when re-run" do
    save!
    save!
    expect(profile.educations.count).to eq(1)
    expect(profile.candidate_skills.matched.count).to eq(1)
  end
end
