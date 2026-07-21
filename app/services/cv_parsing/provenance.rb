module CvParsing
  class Provenance
    FIELD_PATHS = {
      first_name: "personal_details.first_name",
      last_name: "personal_details.last_name",
      email: "personal_details.email",
      phone: "personal_details.phone",
      city: "personal_details.city",
      country: "personal_details.country",
      years_of_experience: "employment.years_of_experience",
      big_registration_status: "employment.big_status",
      big_number: "employment.big_number",
      available_from: "availability.available_from",
      notice_period: "availability.notice_period",
      professional_summary: "summary",
      job_function_id: "job_preferences.suggested_job_function"
    }.freeze

    def initialize(parsed:, profile_attributes:, low_confidence:)
      @parsed = parsed
      @profile_attributes = profile_attributes
      @low_confidence = low_confidence
    end

    def call
      FIELD_PATHS.each_with_object({}) do |(field, path), metadata|
        next unless @profile_attributes.key?(field)

        entry = { "source" => "cv" }
        entry["needs_review"] = true if @low_confidence.include?(path)
        metadata[field.to_s] = entry
      end
    end
  end
end
