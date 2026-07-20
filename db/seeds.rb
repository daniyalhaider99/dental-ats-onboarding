require_relative "seeds/reference_data"

Seeds::ReferenceData.call

puts "Seeded #{JobFunction.count} job functions, #{Skill.count} skills, " \
     "#{Region.count} regions, #{EmploymentType.count} employment types, " \
     "#{WorkingDay.count} working days, #{TransportType.count} transport types, " \
     "#{Language.count} languages."
