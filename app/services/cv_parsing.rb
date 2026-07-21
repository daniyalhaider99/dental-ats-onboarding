module CvParsing
  Error = Class.new(StandardError)

  EmptyExtractionError = Class.new(Error)
  UnsupportedFormatError = Class.new(Error)
  ExtractionToolMissingError = Class.new(Error)

  InvalidResponseError = Class.new(Error)
  ApiError = Class.new(Error)
end
