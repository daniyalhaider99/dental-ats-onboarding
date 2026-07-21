module FixtureHelpers
  def cv_fixture_path(name = "sample.pdf")
    Rails.root.join("spec/fixtures/files", name)
  end
end

RSpec.configure do |config|
  config.include FixtureHelpers
end
