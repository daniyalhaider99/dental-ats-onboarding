module AttributeCoercion
  module_function

  def iso_date(value)
    return if value.blank?

    Date.iso8601(value.to_s)
  rescue ArgumentError, TypeError
    nil
  end

  def text(value)
    value.to_s.strip.presence
  end

  def boolean(value)
    ActiveModel::Type::Boolean.new.cast(value) || false
  end

  def integer(value)
    Integer(value.to_s.strip, exception: false)
  end

  def decimal(value)
    string = value.to_s.strip
    return if string.blank?

    BigDecimal(string)
  rescue ArgumentError
    nil
  end
end
