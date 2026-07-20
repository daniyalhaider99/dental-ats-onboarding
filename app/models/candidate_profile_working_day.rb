class CandidateProfileWorkingDay < ApplicationRecord
  belongs_to :candidate_profile, inverse_of: :candidate_profile_working_days
  belongs_to :working_day

  validates :working_day_id, uniqueness: { scope: :candidate_profile_id }
end
