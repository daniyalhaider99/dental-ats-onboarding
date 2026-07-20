class Skill < ReferenceRecord
  belongs_to :skill_group, inverse_of: :skills

  has_many :candidate_skills, dependent: :restrict_with_error, inverse_of: :skill
  has_many :candidate_profiles, through: :candidate_skills

  validates :slug, uniqueness: { scope: :skill_group_id }

  scope :in_group, ->(skill_group) { where(skill_group: skill_group) }
end
