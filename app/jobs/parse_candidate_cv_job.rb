class ParseCandidateCvJob < ApplicationJob
  queue_as :default

  discard_on ActiveJob::DeserializationError

  retry_on CvParsing::ApiError, wait: :polynomially_longer, attempts: 3 do |job, error|
    document = job.arguments.first
    next unless document.is_a?(CandidateDocument)

    document.update!(
      parsing_status: :failed,
      parsed_at: Time.current,
      parsing_error: "CV parsing failed after repeated attempts: #{error.message}"
    )
  end

  def perform(document)
    return if document.parsing_completed?

    CvParsing::RunPipeline.call(document)
  end
end
