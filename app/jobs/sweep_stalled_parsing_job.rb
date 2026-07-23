class SweepStalledParsingJob < ApplicationJob
  queue_as :default

  def perform
    CandidateDocument.parsing_stalled.find_each do |document|
      next unless document.fail_as_stalled!

      Onboarding::StatusBroadcast.call(document.candidate_profile)
    end
  end
end
