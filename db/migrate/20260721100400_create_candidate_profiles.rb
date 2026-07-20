class CreateCandidateProfiles < ActiveRecord::Migration[8.1]
  def change
    create_table :candidate_profiles, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :user, type: :uuid, null: true, foreign_key: true, index: { unique: true }

      t.references :job_function, type: :uuid, null: true, foreign_key: true

      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :phone
      t.string :city
      t.string :country

      t.integer :max_travel_time_minutes
      t.integer :search_status
      t.text    :reason_for_looking

      t.decimal :desired_gross_salary,    precision: 10, scale: 2
      t.decimal :desired_percentage,      precision: 5,  scale: 2
      t.decimal :average_daily_revenue,   precision: 10, scale: 2
      t.integer :big_registration_status
      t.string  :big_number
      t.integer :years_of_experience

      t.date   :available_from
      t.string :notice_period

      t.text :motivation
      t.text :internal_notes
      t.text :professional_summary

      t.integer :status, null: false, default: 0

      t.jsonb :extraction_metadata, null: false, default: {}

      t.datetime :consented_at

      t.timestamps

      t.index :status
      t.index :email
    end

    add_check_constraint :candidate_profiles,
                         "desired_percentage IS NULL OR (desired_percentage >= 0 AND desired_percentage <= 100)",
                         name: "chk_candidate_profiles_percentage_range"

    add_check_constraint :candidate_profiles,
                         "years_of_experience IS NULL OR years_of_experience >= 0",
                         name: "chk_candidate_profiles_experience_non_negative"

    add_check_constraint :candidate_profiles,
                         "desired_gross_salary IS NULL OR desired_gross_salary >= 0",
                         name: "chk_candidate_profiles_salary_non_negative"

    add_check_constraint :candidate_profiles,
                         "average_daily_revenue IS NULL OR average_daily_revenue >= 0",
                         name: "chk_candidate_profiles_revenue_non_negative"

    add_check_constraint :candidate_profiles,
                         "max_travel_time_minutes IS NULL OR max_travel_time_minutes >= 0",
                         name: "chk_candidate_profiles_travel_time_non_negative"

    add_check_constraint :candidate_profiles,
                         "status = 0 OR consented_at IS NOT NULL",
                         name: "chk_candidate_profiles_completed_requires_consent"
  end
end
