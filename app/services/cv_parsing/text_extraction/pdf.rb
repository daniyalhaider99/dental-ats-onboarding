module CvParsing
  module TextExtraction
    class Pdf < Base
      private

      def extract(file)
        reader = PDF::Reader.new(file)
        reader.pages.map(&:text).join("\n")
      rescue PDF::Reader::MalformedPDFError, PDF::Reader::UnsupportedFeatureError => e
        raise EmptyExtractionError, "the PDF could not be read: #{e.message}"
      end
    end
  end
end
