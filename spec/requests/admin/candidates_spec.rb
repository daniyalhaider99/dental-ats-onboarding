require "rails_helper"

RSpec.describe "Admin candidates" do
  before { seed_reference_data }

  let(:profile) { create(:candidate_profile, :prefilled, :completed, job_function: JobFunction.find_by(slug: "general_dentist")) }

  def admin_headers(user = "admin", password = "password")
    { "Authorization" => ActionController::HttpAuthentication::Basic.encode_credentials(user, password) }
  end

  it "lists candidates" do
    profile
    get admin_candidates_path, headers: admin_headers
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Anna de Vries")
  end

  it "shows a candidate profile" do
    create(:education, candidate_profile: profile, study: "Tandheelkunde")
    get admin_candidate_path(profile), headers: admin_headers
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Tandheelkunde")
  end

  describe "CV download" do
    it "redirects to a signed blob route when a CV is attached" do
      create(:candidate_document, :completed, candidate_profile: profile)
      get admin_candidate_cv_path(profile), headers: admin_headers
      expect(response).to redirect_to(%r{/rails/active_storage/})
    end

    it "redirects back with a notice when no CV is attached" do
      get admin_candidate_cv_path(profile), headers: admin_headers
      expect(response).to redirect_to(admin_candidate_path(profile))
    end
  end

  describe "HTTP basic auth" do
    it "challenges a request with no credentials" do
      get admin_candidates_path
      expect(response).to have_http_status(:unauthorized)
    end

    it "rejects wrong credentials" do
      get admin_candidates_path, headers: admin_headers("admin", "wrong")
      expect(response).to have_http_status(:unauthorized)
    end

    it "honours credentials configured through the environment" do
      ENV["ADMIN_USERNAME"] = "recruiter"
      ENV["ADMIN_PASSWORD"] = "s3cret"

      get admin_candidates_path, headers: admin_headers("recruiter", "s3cret")
      expect(response).to have_http_status(:ok)
    ensure
      ENV.delete("ADMIN_USERNAME")
      ENV.delete("ADMIN_PASSWORD")
    end
  end
end
