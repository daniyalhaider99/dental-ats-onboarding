require "rails_helper"

RSpec.describe "Admin candidates" do
  before { seed_reference_data }

  let(:profile) { create(:candidate_profile, :prefilled, :completed, job_function: JobFunction.find_by(slug: "general_dentist")) }

  it "lists candidates" do
    profile
    get admin_candidates_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Anna de Vries")
  end

  describe "optional HTTP basic auth" do
    around do |example|
      ENV["ADMIN_USERNAME"] = "recruiter"
      ENV["ADMIN_PASSWORD"] = "s3cret"
      example.run
    ensure
      ENV.delete("ADMIN_USERNAME")
      ENV.delete("ADMIN_PASSWORD")
    end

    it "challenges an unauthenticated request when credentials are configured" do
      get admin_candidates_path
      expect(response).to have_http_status(:unauthorized)
    end

    it "allows a request with the correct credentials" do
      credentials = ActionController::HttpAuthentication::Basic.encode_credentials("recruiter", "s3cret")
      get admin_candidates_path, headers: { "Authorization" => credentials }
      expect(response).to have_http_status(:ok)
    end

    it "rejects wrong credentials" do
      credentials = ActionController::HttpAuthentication::Basic.encode_credentials("recruiter", "wrong")
      get admin_candidates_path, headers: { "Authorization" => credentials }
      expect(response).to have_http_status(:unauthorized)
    end
  end

  it "shows a candidate profile" do
    create(:education, candidate_profile: profile, study: "Tandheelkunde")
    get admin_candidate_path(profile)
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Tandheelkunde")
  end

  describe "CV download" do
    it "redirects to a signed blob route when a CV is attached" do
      create(:candidate_document, :completed, candidate_profile: profile)
      get admin_candidate_cv_path(profile)
      expect(response).to redirect_to(%r{/rails/active_storage/})
    end

    it "redirects back with a notice when no CV is attached" do
      get admin_candidate_cv_path(profile)
      expect(response).to redirect_to(admin_candidate_path(profile))
    end
  end
end
