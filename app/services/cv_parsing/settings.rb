module CvParsing
  module Settings
    module_function

    def config
      Rails.application.config_for(:cv_parsing)
    end

    def max_file_size
      config.fetch(:max_file_size_megabytes).megabytes
    end

    def max_file_size_megabytes
      config.fetch(:max_file_size_megabytes)
    end

    def accepted_content_types
      config.fetch(:accepted_content_types)
    end

    def openai
      config.fetch(:openai)
    end

    def openai_model
      openai.fetch(:model)
    end

    def openai_temperature
      openai.fetch(:temperature)
    end

    def request_timeout
      openai.fetch(:request_timeout_seconds)
    end

    def max_attempts
      openai.fetch(:max_attempts)
    end
  end
end
