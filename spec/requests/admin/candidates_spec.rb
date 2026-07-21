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
