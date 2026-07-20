class CandidateProfileTransportType < ApplicationRecord
  belongs_to :candidate_profile, inverse_of: :candidate_profile_transport_types
  belongs_to :transport_type

  validates :transport_type_id, uniqueness: { scope: :candidate_profile_id }
end
