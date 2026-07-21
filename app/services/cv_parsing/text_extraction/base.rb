module CvParsing
  module TextExtraction
    class Base
      MINIMUM_MEANINGFUL_LENGTH = 30

      def self.call(document)
        new(document).call
      end

      def initialize(document)
        @document = document
      end

      def call
        text = document.file.blob.open { |file| extract(file) }
        normalized = normalize(text)

        if normalized.length < MINIMUM_MEANINGFUL_LENGTH
          raise EmptyExtractionError, "no meaningful text could be extracted from #{document.original_filename}"
        end

        normalized
      end

      private

      attr_reader :document

      def extract(_file)
        raise NotImplementedError
      end

      def normalize(text)
        text.to_s
            .unicode_normalize(:nfkc)
            .gsub(/\r\n?/, "\n")
            .gsub(/[ \t]+/, " ")
            .gsub(/\n{3,}/, "\n\n")
            .strip
      end
    end
  end
end
