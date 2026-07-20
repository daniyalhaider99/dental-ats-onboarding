class ReferenceRecord < ApplicationRecord
  self.abstract_class = true

  SLUG_FORMAT = /\A[a-z0-9]+(?:_[a-z0-9]+)*\z/

  validates :name, presence: true
  validates :slug, presence: true, format: {
    with: SLUG_FORMAT,
    message: "must be lowercase alphanumeric words separated by underscores"
  }
  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  scope :active,  -> { where(active: true) }
  scope :ordered, -> { order(:position, :name) }

  def to_s = name
end
