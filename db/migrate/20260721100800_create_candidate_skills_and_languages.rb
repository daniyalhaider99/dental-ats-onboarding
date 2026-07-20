class CreateCandidateSkillsAndLanguages < ActiveRecord::Migration[8.1]
  def change
    create_table :candidate_skills, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :candidate_profile, type: :uuid, null: false, foreign_key: true

      t.references :skill, type: :uuid, null: true, foreign_key: true
      t.string     :free_text_suggestion

      t.integer :source, null: false, default: 0

      t.timestamps

      t.index %i[candidate_profile_id skill_id], unique: true
    end

    add_check_constraint :candidate_skills,
                         "(skill_id IS NULL) <> (free_text_suggestion IS NULL)",
                         name: "chk_candidate_skills_matched_xor_suggested"

    create_table :candidate_languages, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :candidate_profile, type: :uuid, null: false, foreign_key: true
      t.references :language,          type: :uuid, null: false, foreign_key: true

      t.integer :proficiency

      t.timestamps

      t.index %i[candidate_profile_id language_id], unique: true
    end
  end
end
