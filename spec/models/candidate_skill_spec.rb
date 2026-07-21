require "rails_helper"

RSpec.describe CandidateSkill do
  let(:profile) { create(:candidate_profile) }
  let(:skill) { create(:skill) }

  it "is valid when it references a platform skill" do
    expect(CandidateSkill.new(candidate_profile: profile, skill: skill)).to be_valid
  end

  it "is valid as a free-text suggestion" do
    record = CandidateSkill.new(candidate_profile: profile, free_text_suggestion: "Botox")
    expect(record).to be_valid
  end

  it "rejects a row that is both matched and suggested" do
    record = CandidateSkill.new(candidate_profile: profile, skill: skill, free_text_suggestion: "x")
    expect(record).to be_invalid
  end

  it "rejects a row that is neither matched nor suggested" do
    expect(CandidateSkill.new(candidate_profile: profile)).to be_invalid
  end

  it "prevents the same skill twice on one profile" do
    CandidateSkill.create!(candidate_profile: profile, skill: skill)
    dup = CandidateSkill.new(candidate_profile: profile, skill: skill)
    expect(dup).to be_invalid
  end
end
