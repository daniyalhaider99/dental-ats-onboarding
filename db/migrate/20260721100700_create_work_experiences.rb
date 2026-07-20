class CreateWorkExperiences < ActiveRecord::Migration[8.1]
  def change
    create_table :work_experiences, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :candidate_profile, type: :uuid, null: false, foreign_key: true

      t.string  :job_title,    null: false
      t.string  :company_name, null: false
      t.text    :responsibilities
      t.date    :start_date
      t.date    :end_date
      t.boolean :current_job, null: false, default: false
      t.integer :position,    null: false, default: 0

      t.timestamps

      t.index %i[candidate_profile_id position]
    end

    add_check_constraint :work_experiences,
                         "start_date IS NULL OR end_date IS NULL OR end_date >= start_date",
                         name: "chk_work_experiences_end_after_start"

    # A job the candidate still holds cannot also have an end date.
    add_check_constraint :work_experiences,
                         "NOT (current_job AND end_date IS NOT NULL)",
                         name: "chk_work_experiences_current_job_has_no_end_date"
  end
end
