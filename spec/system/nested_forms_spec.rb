require "rails_helper"

RSpec.describe "Nested education and work experience", type: :system, js: true do
  before do
    seed_reference_data
    ActiveJob::Base.queue_adapter = :inline
    stub_openai_extraction(
      "personal_details" => { "first_name" => "Anna", "last_name" => "de Vries", "email" => "anna@example.nl", "phone" => "+31612345678", "city" => "Amsterdam", "country" => "Netherlands" },
      "job_preferences" => { "current_job_title" => "Tandarts", "suggested_job_function" => "general_dentist" },
      "employment" => { "big_status" => "registered", "big_number" => "12345678901", "years_of_experience" => 7 },
      "educations" => [ { "institution" => "UvA", "study" => "Tandheelkunde", "city_and_country" => "Amsterdam", "level" => "master", "start_date" => "2010-09-01", "end_date" => "2016-06-30" } ],
      "work_experiences" => [],
      "languages" => [ { "name" => "Dutch", "proficiency" => "native" } ],
      "skills" => [ "Endodontics" ],
      "availability" => { "available_from" => nil, "notice_period" => nil },
      "summary" => nil,
      "low_confidence_fields" => []
    )
  end

  it "adds and removes education rows" do
    complete_upload

    within("section", text: "Education") do
      expect(visible_rows.count).to eq(1)

      click_button "Add education"
      expect(visible_rows.count).to eq(2)

      within(visible_rows.last) { fill_in "Study / course", with: "Orthodontics course" }
      within(visible_rows.last) { click_button "Remove" }

      expect(visible_rows.count).to eq(1)
    end
  end

  it "adds a work experience and disables the end date for a current job" do
    complete_upload

    within("section", text: "Work experience") do
      expect(visible_rows.count).to eq(0)

      click_button "Add work experience"
      expect(visible_rows.count).to eq(1)

      within(visible_rows.last) do
        check "This is my current job"
        within("[data-current-job-target='endDate']") do
          expect(find("input[type=date]")).to be_disabled
        end
      end
    end
  end

  def complete_upload
    visit root_path
    attach_file "onboarding_upload_form[file]", cv_fixture_path
    check "onboarding_upload_form[consent]"
    click_button "Analyze CV"
    expect(page).to have_content("review every field").or have_content("prefilled")
  end

  def visible_rows
    all("[data-nested-form-target='row']", visible: true)
  end
end
