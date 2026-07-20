class CreateCandidateSkillsAndLanguages < ActiveRecord::Migration[8.1]
  def change
    create_table :candidate_skills, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :candidate_profile, type: :uuid, null: false, foreign_key: true

      # Null when the CV mentioned a skill the platform does not know yet. PRD 3.6
      # asks for those to be kept for recruiter review, and this keeps unvetted
      # strings out of the canonical skills table.
      t.references :skill, type: :uuid, null: true, foreign_key: true
      t.string     :free_text_suggestion

      # Whether the parser proposed this skill or the candidate picked it. Drives the
      # "Extracted from CV" badge on individual skill chips.
      t.integer :source, null: false, default: 0

      t.timestamps

      t.index %i[candidate_profile_id skill_id], unique: true
    end

    # Exactly one of the two: a matched skill or a free-text suggestion, never both
    # and never neither.
    add_check_constraint :candidate_skills,
                         "(skill_id IS NULL) <> (free_text_suggestion IS NULL)",
                         name: "chk_candidate_skills_matched_xor_suggested"

    create_table :candidate_languages, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :candidate_profile, type: :uuid, null: false, foreign_key: true
      t.references :language,          type: :uuid, null: false, foreign_key: true

      # Optional: CVs frequently list a language with no stated level (PRD 3.1).
      t.integer :proficiency

      t.timestamps

      t.index %i[candidate_profile_id language_id], unique: true
    end
  end
end
