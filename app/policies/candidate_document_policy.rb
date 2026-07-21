class CandidateDocumentPolicy
  def initialize(actor:, document:)
    @actor = actor
    @document = document
  end

  # No authentication in the MVP, so an admin actor may always view a CV. The rule
  # lives here so that adding real recruiter accounts later is a change in one place
  # rather than across every controller that serves a file.
  def download?
    @actor == :admin
  end

  private

  attr_reader :actor, :document
end
