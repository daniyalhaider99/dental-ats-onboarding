class TransportType < ReferenceRecord
  validates :slug, uniqueness: true
end
