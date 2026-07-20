class CandidateProfileEmploymentType < ApplicationRecord
  belongs_to :candidate_profile, inverse_of: :candidate_profile_employment_types
  belongs_to :employment_type

  validates :employment_type_id, uniqueness: { scope: :candidate_profile_id }
end
