require "rails_helper"

RSpec.describe User do
  subject { build(:user) }

  it { is_expected.to have_one(:candidate_profile).dependent(:nullify) }
  it { is_expected.to validate_presence_of(:email) }
  it { is_expected.to validate_uniqueness_of(:email).case_insensitive }

  it "downcases and strips the email" do
    user = User.create!(email: "  Anna@Example.NL ")
    expect(user.email).to eq("anna@example.nl")
  end
end
