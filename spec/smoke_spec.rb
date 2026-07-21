require "rails_helper"

RSpec.describe "Application boot" do
  it "loads the Rails environment in the test env" do
    expect(Rails.env).to eq("test")
  end

  it "has the reference data models autoloaded" do
    expect(defined?(CandidateProfile)).to eq("constant")
  end
end
