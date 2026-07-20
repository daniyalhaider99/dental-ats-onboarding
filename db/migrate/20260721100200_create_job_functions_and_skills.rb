class CreateJobFunctionsAndSkills < ActiveRecord::Migration[8.1]
  def change
    create_table :job_functions, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.string  :slug,     null: false
      t.string  :name,     null: false
      t.integer :position, null: false, default: 0
      t.boolean :active,   null: false, default: true

      t.boolean :requires_big_registration, null: false, default: false

      t.boolean :revenue_relevant, null: false, default: false

      t.references :skill_group, type: :uuid, null: false, foreign_key: true

      t.timestamps

      t.index :slug, unique: true
      t.index %i[active position]
    end

    create_table :skills, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.string     :slug,     null: false
      t.string     :name,     null: false
      t.integer    :position, null: false, default: 0
      t.boolean    :active,   null: false, default: true
      t.references :skill_group, type: :uuid, null: false, foreign_key: true

      t.timestamps

      t.index %i[skill_group_id slug], unique: true
      t.index %i[skill_group_id position]
    end
  end
end
