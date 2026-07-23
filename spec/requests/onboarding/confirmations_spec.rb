require "rails_helper"

RSpec.describe "Onboarding confirmation" do
  before { seed_reference_data }

  it "redirects to the start when there is no completed profile in the session" do
    get onboarding_confirmation_path
    expect(response).to redirect_to(root_path)
  end
end
