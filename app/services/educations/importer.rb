module Educations
  class Importer
    LEVELS = Education.levels.keys.to_set

    def self.call(records)
      new.call(records)
    end

    def call(records)
      Array(records).each_with_index.filter_map do |record, index|
        attributes = map(record, index)
        attributes if attributes[:study].present?
      end
    end

    private

    def map(record, index)
      {
        institution: AttributeCoercion.text(record["institution"]),
        study: AttributeCoercion.text(record["study"]),
        city_and_country: AttributeCoercion.text(record["city_and_country"]),
        level: normalize_level(record["level"]),
        start_date: AttributeCoercion.iso_date(record["start_date"]),
        end_date: AttributeCoercion.iso_date(record["end_date"]),
        position: index
      }
    end

    def normalize_level(value)
      normalized = value.to_s.downcase.strip
      LEVELS.include?(normalized) ? normalized : nil
    end
  end
end
