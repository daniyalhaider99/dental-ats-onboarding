# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_07_21_100901) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "active_storage_attachments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.uuid "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "candidate_documents", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "candidate_profile_id", null: false
    t.string "content_type", null: false
    t.datetime "created_at", null: false
    t.integer "document_type", default: 0, null: false
    t.bigint "file_size", null: false
    t.string "original_filename", null: false
    t.datetime "parsed_at"
    t.text "parsing_error"
    t.integer "parsing_status", default: 0, null: false
    t.jsonb "raw_parser_output"
    t.datetime "updated_at", null: false
    t.index ["candidate_profile_id", "document_type"], name: "idx_on_candidate_profile_id_document_type_11c36f2ca9"
    t.index ["candidate_profile_id"], name: "index_candidate_documents_on_candidate_profile_id"
    t.index ["parsing_status"], name: "index_candidate_documents_on_parsing_status"
    t.check_constraint "(parsing_status = ANY (ARRAY[0, 1])) OR parsed_at IS NOT NULL", name: "chk_candidate_documents_terminal_status_has_parsed_at"
    t.check_constraint "file_size > 0", name: "chk_candidate_documents_file_size_positive"
  end

  create_table "candidate_languages", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "candidate_profile_id", null: false
    t.datetime "created_at", null: false
    t.uuid "language_id", null: false
    t.integer "proficiency"
    t.datetime "updated_at", null: false
    t.index ["candidate_profile_id", "language_id"], name: "idx_on_candidate_profile_id_language_id_e7df01ffda", unique: true
    t.index ["candidate_profile_id"], name: "index_candidate_languages_on_candidate_profile_id"
    t.index ["language_id"], name: "index_candidate_languages_on_language_id"
  end

  create_table "candidate_profile_employment_types", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "candidate_profile_id", null: false
    t.datetime "created_at", null: false
    t.uuid "employment_type_id", null: false
    t.datetime "updated_at", null: false
    t.index ["candidate_profile_id", "employment_type_id"], name: "index_candidate_profile_employment_types_uniqueness", unique: true
    t.index ["candidate_profile_id"], name: "idx_on_candidate_profile_id_5ec3d3b7f2"
    t.index ["employment_type_id"], name: "index_candidate_profile_employment_types_on_employment_type_id"
  end

  create_table "candidate_profile_regions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "candidate_profile_id", null: false
    t.datetime "created_at", null: false
    t.uuid "region_id", null: false
    t.datetime "updated_at", null: false
    t.index ["candidate_profile_id", "region_id"], name: "index_candidate_profile_regions_uniqueness", unique: true
    t.index ["candidate_profile_id"], name: "index_candidate_profile_regions_on_candidate_profile_id"
    t.index ["region_id"], name: "index_candidate_profile_regions_on_region_id"
  end

  create_table "candidate_profile_transport_types", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "candidate_profile_id", null: false
    t.datetime "created_at", null: false
    t.uuid "transport_type_id", null: false
    t.datetime "updated_at", null: false
    t.index ["candidate_profile_id", "transport_type_id"], name: "index_candidate_profile_transport_types_uniqueness", unique: true
    t.index ["candidate_profile_id"], name: "idx_on_candidate_profile_id_fc81fb158b"
    t.index ["transport_type_id"], name: "index_candidate_profile_transport_types_on_transport_type_id"
  end

  create_table "candidate_profile_working_days", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "candidate_profile_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "working_day_id", null: false
    t.index ["candidate_profile_id", "working_day_id"], name: "index_candidate_profile_working_days_uniqueness", unique: true
    t.index ["candidate_profile_id"], name: "index_candidate_profile_working_days_on_candidate_profile_id"
    t.index ["working_day_id"], name: "index_candidate_profile_working_days_on_working_day_id"
  end

  create_table "candidate_profiles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.date "available_from"
    t.decimal "average_daily_revenue", precision: 10, scale: 2
    t.string "big_number"
    t.integer "big_registration_status"
    t.string "city"
    t.datetime "consented_at"
    t.string "country"
    t.datetime "created_at", null: false
    t.decimal "desired_gross_salary", precision: 10, scale: 2
    t.decimal "desired_percentage", precision: 5, scale: 2
    t.string "email"
    t.jsonb "extraction_metadata", default: {}, null: false
    t.string "first_name"
    t.text "internal_notes"
    t.uuid "job_function_id"
    t.string "last_name"
    t.integer "max_travel_time_minutes"
    t.text "motivation"
    t.string "notice_period"
    t.string "phone"
    t.text "professional_summary"
    t.text "reason_for_looking"
    t.integer "search_status"
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id"
    t.integer "years_of_experience"
    t.index ["email"], name: "index_candidate_profiles_on_email"
    t.index ["job_function_id"], name: "index_candidate_profiles_on_job_function_id"
    t.index ["status"], name: "index_candidate_profiles_on_status"
    t.index ["user_id"], name: "index_candidate_profiles_on_user_id", unique: true
    t.check_constraint "average_daily_revenue IS NULL OR average_daily_revenue >= 0::numeric", name: "chk_candidate_profiles_revenue_non_negative"
    t.check_constraint "desired_gross_salary IS NULL OR desired_gross_salary >= 0::numeric", name: "chk_candidate_profiles_salary_non_negative"
    t.check_constraint "desired_percentage IS NULL OR desired_percentage >= 0::numeric AND desired_percentage <= 100::numeric", name: "chk_candidate_profiles_percentage_range"
    t.check_constraint "max_travel_time_minutes IS NULL OR max_travel_time_minutes >= 0", name: "chk_candidate_profiles_travel_time_non_negative"
    t.check_constraint "status = 0 OR consented_at IS NOT NULL", name: "chk_candidate_profiles_completed_requires_consent"
    t.check_constraint "years_of_experience IS NULL OR years_of_experience >= 0", name: "chk_candidate_profiles_experience_non_negative"
  end

  create_table "candidate_skills", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "candidate_profile_id", null: false
    t.datetime "created_at", null: false
    t.string "free_text_suggestion"
    t.uuid "skill_id"
    t.integer "source", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["candidate_profile_id", "skill_id"], name: "index_candidate_skills_on_candidate_profile_id_and_skill_id", unique: true
    t.index ["candidate_profile_id"], name: "index_candidate_skills_on_candidate_profile_id"
    t.index ["skill_id"], name: "index_candidate_skills_on_skill_id"
    t.check_constraint "(skill_id IS NULL) <> (free_text_suggestion IS NULL)", name: "chk_candidate_skills_matched_xor_suggested"
  end

  create_table "educations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "candidate_profile_id", null: false
    t.string "city_and_country"
    t.datetime "created_at", null: false
    t.date "end_date"
    t.string "institution"
    t.integer "level"
    t.integer "position", default: 0, null: false
    t.date "start_date"
    t.string "study", null: false
    t.datetime "updated_at", null: false
    t.index ["candidate_profile_id", "position"], name: "index_educations_on_candidate_profile_id_and_position"
    t.index ["candidate_profile_id"], name: "index_educations_on_candidate_profile_id"
    t.check_constraint "start_date IS NULL OR end_date IS NULL OR end_date >= start_date", name: "chk_educations_end_after_start"
  end

  create_table "employment_types", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.integer "compensation_basis", default: 0, null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "position", default: 0, null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["active", "position"], name: "index_employment_types_on_active_and_position"
    t.index ["compensation_basis"], name: "index_employment_types_on_compensation_basis"
    t.index ["slug"], name: "index_employment_types_on_slug", unique: true
  end

  create_table "job_functions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "position", default: 0, null: false
    t.boolean "requires_big_registration", default: false, null: false
    t.boolean "revenue_relevant", default: false, null: false
    t.uuid "skill_group_id", null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["active", "position"], name: "index_job_functions_on_active_and_position"
    t.index ["skill_group_id"], name: "index_job_functions_on_skill_group_id"
    t.index ["slug"], name: "index_job_functions_on_slug", unique: true
  end

  create_table "languages", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "position", default: 0, null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["active", "position"], name: "index_languages_on_active_and_position"
    t.index ["slug"], name: "index_languages_on_slug", unique: true
  end

  create_table "regions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "position", default: 0, null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["active", "position"], name: "index_regions_on_active_and_position"
    t.index ["slug"], name: "index_regions_on_slug", unique: true
  end

  create_table "skill_groups", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "position", default: 0, null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["active", "position"], name: "index_skill_groups_on_active_and_position"
    t.index ["slug"], name: "index_skill_groups_on_slug", unique: true
  end

  create_table "skills", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "position", default: 0, null: false
    t.uuid "skill_group_id", null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["skill_group_id", "position"], name: "index_skills_on_skill_group_id_and_position"
    t.index ["skill_group_id", "slug"], name: "index_skills_on_skill_group_id_and_slug", unique: true
    t.index ["skill_group_id"], name: "index_skills_on_skill_group_id"
  end

  create_table "transport_types", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "position", default: 0, null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["active", "position"], name: "index_transport_types_on_active_and_position"
    t.index ["slug"], name: "index_transport_types_on_slug", unique: true
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.citext "email", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "work_experiences", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "candidate_profile_id", null: false
    t.string "company_name", null: false
    t.datetime "created_at", null: false
    t.boolean "current_job", default: false, null: false
    t.date "end_date"
    t.string "job_title", null: false
    t.integer "position", default: 0, null: false
    t.text "responsibilities"
    t.date "start_date"
    t.datetime "updated_at", null: false
    t.index ["candidate_profile_id", "position"], name: "index_work_experiences_on_candidate_profile_id_and_position"
    t.index ["candidate_profile_id"], name: "index_work_experiences_on_candidate_profile_id"
    t.check_constraint "NOT (current_job AND end_date IS NOT NULL)", name: "chk_work_experiences_current_job_has_no_end_date"
    t.check_constraint "start_date IS NULL OR end_date IS NULL OR end_date >= start_date", name: "chk_work_experiences_end_after_start"
  end

  create_table "working_days", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "position", default: 0, null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["active", "position"], name: "index_working_days_on_active_and_position"
    t.index ["slug"], name: "index_working_days_on_slug", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "candidate_documents", "candidate_profiles"
  add_foreign_key "candidate_languages", "candidate_profiles"
  add_foreign_key "candidate_languages", "languages"
  add_foreign_key "candidate_profile_employment_types", "candidate_profiles"
  add_foreign_key "candidate_profile_employment_types", "employment_types"
  add_foreign_key "candidate_profile_regions", "candidate_profiles"
  add_foreign_key "candidate_profile_regions", "regions"
  add_foreign_key "candidate_profile_transport_types", "candidate_profiles"
  add_foreign_key "candidate_profile_transport_types", "transport_types"
  add_foreign_key "candidate_profile_working_days", "candidate_profiles"
  add_foreign_key "candidate_profile_working_days", "working_days"
  add_foreign_key "candidate_profiles", "job_functions"
  add_foreign_key "candidate_profiles", "users"
  add_foreign_key "candidate_skills", "candidate_profiles"
  add_foreign_key "candidate_skills", "skills"
  add_foreign_key "educations", "candidate_profiles"
  add_foreign_key "job_functions", "skill_groups"
  add_foreign_key "skills", "skill_groups"
  add_foreign_key "work_experiences", "candidate_profiles"
end
