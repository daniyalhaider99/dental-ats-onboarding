require "rails_helper"

RSpec.describe Education do
  it { is_expected.to validate_presence_of(:study) }

  it "rejects an end date before the start date" do
    record = build(:education, start_date: Date.new(2016, 1, 1), end_date: Date.new(2010, 1, 1))
    expect(record).to be_invalid
  end

  it "accepts open-ended dates" do
    expect(build(:education, start_date: nil, end_date: nil)).to be_valid
  end
end
