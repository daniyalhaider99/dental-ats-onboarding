class SkillGroup < ReferenceRecord
  has_many :skills, -> { ordered }, dependent: :restrict_with_error, inverse_of: :skill_group
  has_many :job_functions, dependent: :restrict_with_error, inverse_of: :skill_group

  validates :slug, uniqueness: true
end
