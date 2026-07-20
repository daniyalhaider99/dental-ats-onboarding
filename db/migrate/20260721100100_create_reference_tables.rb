# The platform's fixed vocabularies. PRD section 14 asks for these to be manageable
# from the database rather than hardcoded, so each is a table with a stable slug that
# code refers to and a display name that an admin can safely edit.
class CreateReferenceTables < ActiveRecord::Migration[8.1]
  REFERENCE_TABLES = %i[
    regions
    employment_types
    transport_types
    working_days
    languages
    skill_groups
  ].freeze

  def change
    REFERENCE_TABLES.each do |table|
      create_table table, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
        t.string  :slug,     null: false
        t.string  :name,     null: false
        t.integer :position, null: false, default: 0
        t.boolean :active,   null: false, default: true

        t.timestamps

        t.index :slug, unique: true
        t.index %i[active position]
      end
    end

    # Employment type drives the salary-vs-percentage branch in PRD section 4. Storing
    # the compensation basis on the row keeps that rule out of the view layer.
    add_column :employment_types, :compensation_basis, :integer, null: false, default: 0
    add_index  :employment_types, :compensation_basis
  end
end
