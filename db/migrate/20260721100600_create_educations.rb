class CreateEducations < ActiveRecord::Migration[8.1]
  def change
    create_table :educations, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :candidate_profile, type: :uuid, null: false, foreign_key: true

      t.string  :institution
      t.string  :study, null: false
      t.string  :city_and_country
      t.integer :level
      t.date    :start_date
      t.date    :end_date

      t.integer :position, null: false, default: 0

      t.timestamps

      t.index %i[candidate_profile_id position]
    end

    add_check_constraint :educations,
                         "start_date IS NULL OR end_date IS NULL OR end_date >= start_date",
                         name: "chk_educations_end_after_start"
  end
end
