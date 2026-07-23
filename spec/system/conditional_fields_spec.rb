require "rails_helper"

RSpec.describe "Conditional employment fields", type: :system, js: true do
  before do
    seed_reference_data
    ActiveJob::Base.queue_adapter = :inline
    stub_openai_extraction(
      "personal_details" => { "first_name" => "Anna", "last_name" => "de Vries", "email" => "anna@example.nl", "phone" => "+31612345678", "city" => "Amsterdam", "country" => "Netherlands" },
      "job_preferences" => { "current_job_title" => "Tandarts", "suggested_job_function" => "general_dentist" },
      "employment" => { "big_status" => "registered", "big_number" => "12345678901", "years_of_experience" => 7 },
      "educations" => [], "work_experiences" => [],
      "languages" => [ { "name" => "Dutch", "proficiency" => "native" } ],
      "skills" => [], "availability" => { "available_from" => nil, "notice_period" => nil },
      "summary" => nil, "low_confidence_fields" => []
    )
    complete_upload
  end

  it "shows BIG and revenue for a dentist and hides them for an assistant" do
    expect(page).to have_field("candidate_profile[big_registration_status]")
    expect(page).to have_field("candidate_profile[average_daily_revenue]")

    select "Dental assistant", from: "candidate_profile[job_function_id]"

    expect(page).to have_no_field("candidate_profile[big_registration_status]")
    expect(page).to have_no_field("candidate_profile[average_daily_revenue]")
  end

  it "shows salary for employed and percentage for freelance" do
    expect(page).to have_no_field("candidate_profile[desired_gross_salary]")

    check "Employed"
    expect(page).to have_field("candidate_profile[desired_gross_salary]")
    expect(page).to have_no_field("candidate_profile[desired_percentage]")

    check "Freelance / ZZP"
    expect(page).to have_field("candidate_profile[desired_percentage]")
  end

  it "shows the BIG number only when the status is registered" do
    expect(page).to have_field("candidate_profile[big_number]")

    select "In progress", from: "candidate_profile[big_registration_status]"
    expect(page).to have_no_field("candidate_profile[big_number]")
  end

  it "reloads the skills list when the function changes" do
    select "Dental technician", from: "candidate_profile[job_function_id]"

    within("#candidate_skills") do
      expect(page).to have_content("CAD/CAM")
      expect(page).to have_no_content("Endodontics")
    end
  end

  def complete_upload
    visit new_onboarding_cv_upload_path
    attach_file "onboarding_upload_form[file]", cv_fixture_path
    check "onboarding_upload_form[consent]"
    click_button "Analyze CV"
    expect(page).to have_content("review every field").or have_content("prefilled")
  end
end
