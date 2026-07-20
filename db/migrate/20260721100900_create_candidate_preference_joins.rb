class CreateCandidatePreferenceJoins < ActiveRecord::Migration[8.1]
  JOINS = {
    candidate_profile_regions:          :region,
    candidate_profile_employment_types: :employment_type,
    candidate_profile_transport_types:  :transport_type,
    candidate_profile_working_days:     :working_day
  }.freeze

  def change
    JOINS.each do |table, reference|
      create_table table, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
        t.references :candidate_profile, type: :uuid, null: false, foreign_key: true
        t.references reference,          type: :uuid, null: false, foreign_key: true

        t.timestamps

        t.index %i[candidate_profile_id] + [ :"#{reference}_id" ],
                unique: true,
                name: "index_#{table}_uniqueness"
      end
    end
  end
end
