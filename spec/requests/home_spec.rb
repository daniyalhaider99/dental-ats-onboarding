require "rails_helper"

RSpec.describe "Home landing page" do
  it "renders the two entry points" do
    get root_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("I'm a candidate").and include("I'm a recruiter")
    expect(response.body).to include(new_onboarding_cv_upload_path)
    expect(response.body).to include(admin_candidates_path)
  end
end
