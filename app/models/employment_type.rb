class EmploymentType < ReferenceRecord
  enum :compensation_basis, { salaried: 0, percentage_based: 1 }, prefix: :basis

  validates :slug, uniqueness: true

  scope :salaried_basis,   -> { where(compensation_basis: :salaried) }
  scope :percentage_basis, -> { where(compensation_basis: :percentage_based) }
end
