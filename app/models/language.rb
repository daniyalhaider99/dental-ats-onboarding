class Language < ReferenceRecord
  validates :slug, uniqueness: true
end
