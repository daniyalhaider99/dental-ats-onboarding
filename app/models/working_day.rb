class WorkingDay < ReferenceRecord
  validates :slug, uniqueness: true
end
