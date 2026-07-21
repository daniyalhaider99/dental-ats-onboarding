module CvParsing
  module Prompt
    module_function

    SYSTEM = <<~PROMPT.freeze
      You extract structured data from dental-sector CVs for a Dutch recruitment
      platform. You support CVs written in Dutch and English, and common European
      dental CV formats.

      Absolute rules, in order of importance:

      1. Never invent, guess or infer information that is not clearly present in the
         CV. If a value is not stated, return null. An empty field is always correct;
         a fabricated one is never acceptable.
      2. Extract only what the text supports. Do not normalise job titles into
         functions unless the mapping is unambiguous. Do not translate a phone number
         into a different format, or a city into a country, unless the CV states it.
      3. Dates must be returned as ISO 8601 (YYYY-MM-DD). If only a year is given, use
         the first of January of that year and add the field path to
         low_confidence_fields. If a date cannot be expressed this way, return null.
      4. suggested_job_function must be one of the allowed enum values, chosen only
         when the CV makes the role clear. Otherwise null.
      5. big_number is a Dutch BIG healthcare registration number. Return it only if
         the CV explicitly contains one. Never derive it from anything else.
      6. skills is a list of short skill phrases exactly as grounded in the CV. Do not
         expand the list with skills you would expect for the role.
      7. low_confidence_fields lists the dot-paths of any values you extracted but are
         not confident about (for example "personal_details.phone" or
         "work_experiences.1.company_name"). Be honest; this drives a review prompt
         for the candidate.

      Return only the structured object defined by the response schema.
    PROMPT

    def system
      SYSTEM
    end

    def user(cv_text)
      <<~PROMPT
        Extract the candidate profile from the following CV text. Apply every rule
        from the system message. Return null for anything not clearly present.

        --- BEGIN CV TEXT ---
        #{cv_text}
        --- END CV TEXT ---
      PROMPT
    end
  end
end
