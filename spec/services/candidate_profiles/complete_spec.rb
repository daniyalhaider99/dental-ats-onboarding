require "rails_helper"

RSpec.describe CandidateProfiles::Complete do
  before { seed_reference_data }

  let(:profile) { create(:candidate_profile) }

  def valid_params
    {
      first_name: "Anna", last_name: "de Vries", email: "anna@example.nl", phone: "+31612345678",
      city: "Amsterdam", country: "Netherlands", job_function_id: JobFunction.find_by(slug: "general_dentist").id,
      search_status: "active", max_travel_time_minutes: 30, years_of_experience: 7, available_from: "2026-09-01",
      big_registration_status: "registered", big_number: "123",
      region_ids: [ Region.first.id ], employment_type_ids: [ EmploymentType.first.id ],
      working_day_ids: [ WorkingDay.first.id ], language_ids: [ Language.find_by(name: "Dutch").id ],
      consent: "1"
    }
  end

  it "completes the profile and links a user by email" do
    result = described_class.call(profile: profile, params: ActionController::Parameters.new(valid_params).permit!)

    expect(result).to be_success
    expect(profile.reload).to be_completed
    expect(profile.user.email).to eq("anna@example.nl")
  end

  it "notifies the recruitment team" do
    allow(Notifications::CandidateOnboardingCompleted).to receive(:call)
    described_class.call(profile: profile, params: ActionController::Parameters.new(valid_params).permit!)
    expect(Notifications::CandidateOnboardingCompleted).to have_received(:call).with(profile)
  end

  it "fails validation without creating a user or masking errors" do
    params = ActionController::Parameters.new(valid_params.merge(first_name: "", email: "bad")).permit!

    expect do
      result = described_class.call(profile: profile, params: params)
      expect(result).to be_failure
    end.not_to change(User, :count)

    expect(profile.reload).not_to be_completed
    expect(profile.errors[:first_name]).to be_present
  end
end
