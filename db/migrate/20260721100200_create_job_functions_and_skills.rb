# Job functions carry the conditional-form rules from PRD section 4 as data.
#
# The alternative was a case statement mapping function slugs to behaviour, which would
# mean a code change and a deploy every time recruitment adds a function. Here the rules
# are columns, so a new function is a seed row, and the same record feeds both the
# server-rendered form and the Stimulus controller that toggles fields client-side.
class CreateJobFunctionsAndSkills < ActiveRecord::Migration[8.1]
  def change
    create_table :job_functions, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.string  :slug,     null: false
      t.string  :name,     null: false
      t.integer :position, null: false, default: 0
      t.boolean :active,   null: false, default: true

      # Show BIG registration status and number. True for dentists, hygienists and
      # specialists; false for assistants, front-office, technicians and managers.
      t.boolean :requires_big_registration, null: false, default: false

      # Show the average daily revenue field.
      t.boolean :revenue_relevant, null: false, default: false

      # Which set of skills renders once this function is selected.
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

      # Scoped rather than global: "prevention" is a legitimate skill in both the
      # hygienist and the assistant group.
      t.index %i[skill_group_id slug], unique: true
      t.index %i[skill_group_id position]
    end
  end
end
