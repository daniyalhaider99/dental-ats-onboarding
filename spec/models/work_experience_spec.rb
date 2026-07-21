require "rails_helper"

RSpec.describe WorkExperience do
  it { is_expected.to validate_presence_of(:job_title) }
  it { is_expected.to validate_presence_of(:company_name) }

  it "rejects an end date before the start date" do
    record = build(:work_experience, start_date: Date.new(2020, 1, 1), end_date: Date.new(2019, 1, 1))
    expect(record).to be_invalid
    expect(record.errors[:end_date]).to be_present
  end

  it "rejects an end date on a job marked as current" do
    record = build(:work_experience, current_job: true, end_date: Date.new(2020, 1, 1))
    expect(record).to be_invalid
  end

  it "accepts a current job with no end date" do
    expect(build(:work_experience, current_job: true, end_date: nil)).to be_valid
  end
end
