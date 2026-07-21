require "rails_helper"

RSpec.describe Skills::Matcher do
  let(:group) { create(:skill_group) }
  let!(:endodontics) { create(:skill, skill_group: group, name: "Endodontics", slug: "endodontics") }

  it "matches a skill by name, case and punctuation insensitively" do
    matches = described_class.call(names: [ "  endodontics! " ], skill_group: group)
    expect(matches.first.skill).to eq(endodontics)
  end

  it "returns a free-text suggestion when there is no match" do
    match = described_class.call(names: [ "Underwater basket weaving" ], skill_group: group).first
    expect(match).not_to be_matched
    expect(match.suggestion).to eq("Underwater basket weaving")
  end

  it "treats everything as a suggestion when no group is given" do
    match = described_class.call(names: [ "Endodontics" ], skill_group: nil).first
    expect(match).not_to be_matched
  end

  it "ignores blank names" do
    expect(described_class.call(names: [ "", nil ], skill_group: group)).to be_empty
  end
end
