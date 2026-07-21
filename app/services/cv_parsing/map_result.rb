module CvParsing
  class MapResult
    def self.call(parsed)
      new(parsed).call
    end

    def initialize(parsed)
      @parsed = parsed.deep_stringify_keys
      @low_confidence = Array(@parsed["low_confidence_fields"]).to_set
    end

    def call
      MappedResult.new(
        profile_attributes: profile_attributes,
        educations: Educations::Importer.call(@parsed["educations"]),
        work_experiences: WorkExperiences::Importer.call(@parsed["work_experiences"]),
        language_names: language_names,
        skill_names: Array(@parsed["skills"]).filter_map { |name| AttributeCoercion.text(name) },
        job_function: job_function,
        extraction_metadata: extraction_metadata
      )
    end

    private

    def personal = @parsed.fetch("personal_details", {})
    def employment = @parsed.fetch("employment", {})
    def availability = @parsed.fetch("availability", {})

    def profile_attributes
      {
        first_name: AttributeCoercion.text(personal["first_name"]),
        last_name: AttributeCoercion.text(personal["last_name"]),
        email: AttributeCoercion.text(personal["email"])&.downcase,
        phone: AttributeCoercion.text(personal["phone"]),
        city: AttributeCoercion.text(personal["city"]),
        country: AttributeCoercion.text(personal["country"]),
        years_of_experience: AttributeCoercion.integer(employment["years_of_experience"]),
        big_registration_status: big_status,
        big_number: AttributeCoercion.text(employment["big_number"]),
        available_from: AttributeCoercion.iso_date(availability["available_from"]),
        notice_period: AttributeCoercion.text(availability["notice_period"]),
        professional_summary: AttributeCoercion.text(@parsed["summary"]),
        job_function_id: job_function&.id
      }.compact
    end

    def big_status
      value = employment["big_status"].to_s.strip
      CandidateProfile.big_registration_statuses.key?(value) ? value : nil
    end

    def job_function
      slug = @parsed.dig("job_preferences", "suggested_job_function").to_s.strip
      return if slug.blank?

      JobFunction.active.find_by(slug: slug)
    end

    def language_names
      Array(@parsed["languages"]).filter_map { |entry| AttributeCoercion.text(entry["name"]) }
    end

    def extraction_metadata
      Provenance.new(
        parsed: @parsed,
        profile_attributes: profile_attributes,
        low_confidence: @low_confidence
      ).call
    end
  end
end
