module WorkExperiences
  class Importer
    def self.call(records)
      new.call(records)
    end

    def call(records)
      Array(records).each_with_index.filter_map do |record, index|
        attributes = map(record, index)
        attributes if attributes[:job_title].present? && attributes[:company_name].present?
      end
    end

    private

    def map(record, index)
      current = AttributeCoercion.boolean(record["current_job"])
      end_date = current ? nil : AttributeCoercion.iso_date(record["end_date"])

      {
        job_title: AttributeCoercion.text(record["job_title"]),
        company_name: AttributeCoercion.text(record["company_name"]),
        responsibilities: AttributeCoercion.text(record["responsibilities"]),
        start_date: AttributeCoercion.iso_date(record["start_date"]),
        end_date: end_date,
        current_job: current,
        position: index
      }
    end
  end
end
