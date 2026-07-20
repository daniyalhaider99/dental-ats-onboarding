class CandidateLanguage < ApplicationRecord
  belongs_to :candidate_profile, inverse_of: :candidate_languages
  belongs_to :language

  enum :proficiency, { a1: 0, a2: 1, b1: 2, b2: 3, c1: 4, c2: 5, native: 6 }, prefix: true

  validates :language_id, uniqueness: { scope: :candidate_profile_id }
end
