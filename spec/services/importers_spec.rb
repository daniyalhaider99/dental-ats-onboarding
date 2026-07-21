require "rails_helper"

RSpec.describe "CV record importers" do
  describe Educations::Importer do
    it "keeps records with a study and drops those without" do
      result = described_class.call([
        { "study" => "Tandheelkunde", "level" => "master", "start_date" => "2010-09-01" },
        { "study" => nil, "institution" => "Nowhere" }
      ])

      expect(result.size).to eq(1)
      expect(result.first).to include(study: "Tandheelkunde", level: "master", start_date: Date.new(2010, 9, 1))
    end

    it "nils out unknown levels and unparseable dates rather than guessing" do
      result = described_class.call([ { "study" => "X", "level" => "banana", "start_date" => "nope" } ])
      expect(result.first).to include(level: nil, start_date: nil)
    end
  end

  describe WorkExperiences::Importer do
    it "requires a job title and a company" do
      result = described_class.call([
        { "job_title" => "Tandarts", "company_name" => "Centrum" },
        { "job_title" => "Assistant", "company_name" => nil }
      ])
      expect(result.size).to eq(1)
    end

    it "clears the end date for a current job" do
      result = described_class.call([
        { "job_title" => "T", "company_name" => "C", "current_job" => true, "end_date" => "2020-01-01" }
      ])
      expect(result.first).to include(current_job: true, end_date: nil)
    end
  end
end
