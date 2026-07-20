class CandidateProfileRegion < ApplicationRecord
  belongs_to :candidate_profile, inverse_of: :candidate_profile_regions
  belongs_to :region

  validates :region_id, uniqueness: { scope: :candidate_profile_id }
end
