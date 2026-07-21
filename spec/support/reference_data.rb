require Rails.root.join("db/seeds/reference_data")

module ReferenceDataHelper
  def seed_reference_data
    Seeds::ReferenceData.call
  end
end

RSpec.configure do |config|
  config.include ReferenceDataHelper
end
