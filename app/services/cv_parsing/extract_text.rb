module CvParsing
  module ExtractText
    module_function

    def call(document)
      text = TextExtraction::Resolver.call(document)
      ServiceResult.success(text)
    rescue Error => e
      ServiceResult.failure(e.message)
    end
  end
end
