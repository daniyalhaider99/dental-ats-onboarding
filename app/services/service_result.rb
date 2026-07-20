class ServiceResult
  attr_reader :value, :error

  def self.success(value = nil)
    new(success: true, value: value)
  end

  def self.failure(error, value: nil)
    new(success: false, error: error, value: value)
  end

  def initialize(success:, value: nil, error: nil)
    @success = success
    @value = value
    @error = error
    freeze
  end

  def success? = @success
  def failure? = !@success
end
