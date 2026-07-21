require "rails_helper"

RSpec.describe CandidateProfile do
  describe "associations" do
    it { is_expected.to belong_to(:user).optional }
    it { is_expected.to belong_to(:job_function).optional }
    it { is_expected.to have_many(:educations).dependent(:destroy) }
    it { is_expected.to have_many(:work_experiences).dependent(:destroy) }
    it { is_expected.to have_many(:candidate_skills).dependent(:destroy) }
    it { is_expected.to have_many(:candidate_documents).dependent(:destroy) }
  end

  describe "always-on validations" do
    it { is_expected.to validate_numericality_of(:desired_percentage).is_greater_than_or_equal_to(0).is_less_than_or_equal_to(100).allow_nil }
    it { is_expected.to validate_numericality_of(:years_of_experience).is_greater_than_or_equal_to(0).allow_nil }

    it "accepts a blank draft so the parser can persist a partial profile" do
      expect(build(:candidate_profile)).to be_valid
    end

    it "rejects an invalid email" do
      profile = build(:candidate_profile, email: "not-an-email")
      expect(profile).to be_invalid
      expect(profile.errors[:email]).to be_present
    end

    it "accepts a Dutch national phone number" do
      expect(build(:candidate_profile, phone: "0612345678")).to be_valid
    end

    it "rejects an unparseable phone number" do
      expect(build(:candidate_profile, phone: "12")).to be_invalid
    end
  end

  describe "review-context validations" do
    subject(:profile) { build(:candidate_profile, consented_at: nil) }

    it "requires the core personal and preference fields" do
      profile.valid?(described_class::REVIEW)

      expect(profile.errors.attribute_names).to include(
        :first_name, :last_name, :email, :phone, :city, :job_function,
        :search_status, :max_travel_time_minutes, :years_of_experience,
        :available_from, :regions, :employment_types, :working_days, :languages, :consented_at
      )
    end
  end

  describe "conditional predicates" do
    it "makes BIG relevant for a function that requires it" do
      fn = build(:job_function, requires_big_registration: true)
      expect(build(:candidate_profile, job_function: fn)).to be_big_registration_relevant
    end

    it "requires a BIG number only when relevant and registered" do
      fn = build(:job_function, requires_big_registration: true)
      profile = build(:candidate_profile, job_function: fn, big_registration_status: :registered)
      expect(profile).to be_big_number_required

      profile.big_registration_status = :in_progress
      expect(profile).not_to be_big_number_required
    end

    it "does not require a BIG number for a function that does not use BIG" do
      fn = build(:job_function, requires_big_registration: false)
      profile = build(:candidate_profile, job_function: fn, big_registration_status: :registered)
      expect(profile).not_to be_big_number_required
    end
  end
end
