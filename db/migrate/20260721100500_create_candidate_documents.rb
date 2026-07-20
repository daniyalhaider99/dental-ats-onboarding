class CreateCandidateDocuments < ActiveRecord::Migration[8.1]
  def change
    create_table :candidate_documents, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :candidate_profile, type: :uuid, null: false, foreign_key: true

      t.integer :document_type, null: false, default: 0

      t.string :original_filename, null: false
      t.string :content_type,      null: false
      t.bigint :file_size,         null: false

      t.integer  :parsing_status, null: false, default: 0
      t.datetime :parsed_at
      t.text     :parsing_error

      t.jsonb :raw_parser_output

      t.timestamps

      t.index %i[candidate_profile_id document_type]
      t.index :parsing_status
    end

    add_check_constraint :candidate_documents,
                         "file_size > 0",
                         name: "chk_candidate_documents_file_size_positive"

    add_check_constraint :candidate_documents,
                         "parsing_status IN (0, 1) OR parsed_at IS NOT NULL",
                         name: "chk_candidate_documents_terminal_status_has_parsed_at"
  end
end
