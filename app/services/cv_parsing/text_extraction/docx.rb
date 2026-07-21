module CvParsing
  module TextExtraction
    class Docx < Base
      private

      def extract(file)
        document = ::Docx::Document.open(file.path)
        paragraphs = document.paragraphs.map(&:text)
        tables = document.tables.flat_map do |table|
          table.rows.map { |row| row.cells.map(&:text).join(" ") }
        end

        (paragraphs + tables).join("\n")
      rescue StandardError => e
        raise EmptyExtractionError, "the DOCX could not be read: #{e.message}"
      end
    end
  end
end
