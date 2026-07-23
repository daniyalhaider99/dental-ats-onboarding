require "rails_helper"

RSpec.describe "Onboarding profiles" do
  before do
    seed_reference_data
    ActiveJob::Base.queue_adapter = :inline
    stub_openai_extraction(
      "personal_details" => { "first_name" => "Anna", "last_name" => "de Vries", "email" => "anna@example.nl", "phone" => "+31612345678", "city" => "Amsterdam", "country" => "Netherlands" },
      "job_preferences" => { "current_job_title" => "Tandarts", "suggested_job_function" => "general_dentist" },
      "employment" => { "big_status" => "registered", "big_number" => "123", "years_of_experience" => 7 },
      "educations" => [], "work_experiences" => [],
      "languages" => [ { "name" => "Dutch", "proficiency" => "native" } ],
      "skills" => [ "Endodontics" ], "availability" => { "available_from" => nil, "notice_period" => nil },
      "summary" => nil, "low_confidence_fields" => [ "personal_details.phone" ]
    )
  end

  context "without a profile in the session" do
    it "redirects to the upload screen" do
      get onboarding_profile_path
      expect(response).to redirect_to(root_path)
    end
  end

  context "after uploading a CV" do
    before do
      post onboarding_cv_upload_path, params: {
        onboarding_upload_form: { file: fixture_file_upload("sample.pdf", "application/pdf"), consent: "1" }
      }
    end

    it "shows the prefilled review form with provenance badges" do
      get onboarding_profile_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Anna").and include("Extracted from CV").and include("Please check")
    end

    it "unsticks a stalled parse into the manual form when the page is viewed" do
      document = CandidateProfile.last.latest_cv
      document.update_columns(parsing_status: CandidateDocument.parsing_statuses[:processing],
                              updated_at: 1.hour.ago)

      get onboarding_profile_path

      expect(response).to have_http_status(:ok)
      expect(document.reload).to be_parsing_failed
      expect(response.body).to include("couldn't read your CV")
    end

    it "returns a turbo stream from the status endpoint" do
      get status_onboarding_profile_path, headers: { "Accept" => "text/vnd.turbo-stream.html" }
      expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      expect(response.body).to include("onboarding_body")
    end

    it "re-renders the skills frame for a chosen function" do
      get skills_onboarding_profile_path, params: { job_function_id: JobFunction.find_by(slug: "dental_technician").id }
      expect(response.body).to include("CAD/CAM")
    end

    it "completes the profile on a valid submit" do
      patch onboarding_profile_path, params: { candidate_profile: valid_submit }
      expect(response).to redirect_to(onboarding_cv_upload_path)
      expect(CandidateProfile.last).to be_completed
    end

    it "re-renders with errors on an invalid submit" do
      patch onboarding_profile_path, params: { candidate_profile: { first_name: "" } }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("to fix")
    end
  end

  def valid_submit
    {
      first_name: "Anna", last_name: "de Vries", email: "anna@example.nl", phone: "+31612345678",
      city: "Amsterdam", country: "Netherlands", job_function_id: JobFunction.find_by(slug: "general_dentist").id,
      search_status: "active", max_travel_time_minutes: 30, years_of_experience: 7, available_from: "2026-09-01",
      big_registration_status: "registered", big_number: "123",
      region_ids: [ Region.first.id ], employment_type_ids: [ EmploymentType.first.id ],
      working_day_ids: [ WorkingDay.first.id ], language_ids: [ Language.find_by(name: "Dutch").id ], consent: "1"
    }
  end
end
