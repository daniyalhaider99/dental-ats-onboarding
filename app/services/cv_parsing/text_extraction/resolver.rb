module CvParsing
  module TextExtraction
    module Resolver
      STRATEGIES = {
        pdf: Pdf,
        docx: Docx,
        doc: Doc
      }.freeze

      module_function

      def call(document)
        strategy_for(document).call(document)
      end

      def strategy_for(document)
        STRATEGIES.fetch(document.format) do
          raise UnsupportedFormatError, "no extractor for #{document.content_type}"
        end
      end
    end
  end
end
