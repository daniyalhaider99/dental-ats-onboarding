class Region < ReferenceRecord
  validates :slug, uniqueness: true
end
