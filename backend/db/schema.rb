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

ActiveRecord::Schema[8.1].define(version: 2025_12_12_104117) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
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

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "bids", force: :cascade do |t|
    t.decimal "amount"
    t.text "cover_letter"
    t.datetime "created_at", null: false
    t.integer "estimated_days"
    t.bigint "freelancer_id", null: false
    t.bigint "job_id", null: false
    t.integer "status"
    t.datetime "updated_at", null: false
    t.index ["freelancer_id"], name: "index_bids_on_freelancer_id"
    t.index ["job_id"], name: "index_bids_on_job_id"
  end

  create_table "contracts", force: :cascade do |t|
    t.bigint "client_id", null: false
    t.datetime "created_at", null: false
    t.bigint "freelancer_id", null: false
    t.bigint "job_id", null: false
    t.integer "status"
    t.decimal "total_amount"
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_contracts_on_client_id"
    t.index ["freelancer_id"], name: "index_contracts_on_freelancer_id"
    t.index ["job_id"], name: "index_contracts_on_job_id"
  end

  create_table "conversations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "participant_1_id", null: false
    t.bigint "participant_2_id", null: false
    t.datetime "updated_at", null: false
    t.index ["participant_1_id"], name: "index_conversations_on_participant_1_id"
    t.index ["participant_2_id"], name: "index_conversations_on_participant_2_id"
  end

  create_table "disputes", force: :cascade do |t|
    t.text "admin_notes"
    t.datetime "created_at", null: false
    t.text "evidence"
    t.bigint "milestone_id", null: false
    t.bigint "raised_by_id", null: false
    t.text "reason", null: false
    t.datetime "resolved_at"
    t.bigint "resolved_by_id"
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_disputes_on_created_at"
    t.index ["milestone_id"], name: "index_disputes_on_milestone_id"
    t.index ["raised_by_id"], name: "index_disputes_on_raised_by_id"
    t.index ["resolved_by_id"], name: "index_disputes_on_resolved_by_id"
    t.index ["status"], name: "index_disputes_on_status"
  end

  create_table "job_skills", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.bigint "skill_id", null: false
    t.datetime "updated_at", null: false
    t.index ["job_id"], name: "index_job_skills_on_job_id"
    t.index ["skill_id"], name: "index_job_skills_on_skill_id"
  end

  create_table "jobs", force: :cascade do |t|
    t.decimal "budget_max"
    t.decimal "budget_min"
    t.integer "budget_type"
    t.bigint "client_id", null: false
    t.datetime "created_at", null: false
    t.date "deadline"
    t.text "description"
    t.integer "status"
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_jobs_on_client_id"
  end

  create_table "jwt_denylists", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "exp", null: false
    t.string "jti", null: false
    t.datetime "updated_at", null: false
    t.index ["jti"], name: "index_jwt_denylists_on_jti", unique: true
  end

  create_table "messages", force: :cascade do |t|
    t.text "body"
    t.bigint "conversation_id", null: false
    t.datetime "created_at", null: false
    t.datetime "read_at"
    t.bigint "sender_id", null: false
    t.datetime "updated_at", null: false
    t.index ["conversation_id"], name: "index_messages_on_conversation_id"
    t.index ["sender_id"], name: "index_messages_on_sender_id"
  end

  create_table "milestones", force: :cascade do |t|
    t.decimal "amount"
    t.bigint "contract_id", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.date "due_date"
    t.string "payment_transaction_id"
    t.integer "status"
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["contract_id"], name: "index_milestones_on_contract_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "kind"
    t.jsonb "payload"
    t.boolean "read"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "reviews", force: :cascade do |t|
    t.text "comment"
    t.bigint "contract_id", null: false
    t.datetime "created_at", null: false
    t.integer "rating"
    t.bigint "reviewed_user_id", null: false
    t.bigint "reviewer_id", null: false
    t.datetime "updated_at", null: false
    t.index ["contract_id"], name: "index_reviews_on_contract_id"
    t.index ["reviewed_user_id"], name: "index_reviews_on_reviewed_user_id"
    t.index ["reviewer_id"], name: "index_reviews_on_reviewer_id"
  end

  create_table "skills", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.string "slug"
    t.datetime "updated_at", null: false
  end

  create_table "transactions", force: :cascade do |t|
    t.decimal "amount"
    t.bigint "client_id", null: false
    t.datetime "created_at", null: false
    t.bigint "milestone_id", null: false
    t.integer "provider"
    t.string "provider_payment_id"
    t.integer "status"
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_transactions_on_client_id"
    t.index ["milestone_id"], name: "index_transactions_on_milestone_id"
  end

  create_table "user_skills", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "skill_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["skill_id"], name: "index_user_skills_on_skill_id"
    t.index ["user_id"], name: "index_user_skills_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "avatar_url"
    t.text "bio"
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.decimal "hourly_rate"
    t.string "location"
    t.string "name"
    t.float "rating_cache"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "role"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "bids", "jobs"
  add_foreign_key "bids", "users", column: "freelancer_id"
  add_foreign_key "contracts", "jobs"
  add_foreign_key "contracts", "users", column: "client_id"
  add_foreign_key "contracts", "users", column: "freelancer_id"
  add_foreign_key "conversations", "users", column: "participant_1_id"
  add_foreign_key "conversations", "users", column: "participant_2_id"
  add_foreign_key "disputes", "milestones"
  add_foreign_key "disputes", "users", column: "raised_by_id"
  add_foreign_key "disputes", "users", column: "resolved_by_id"
  add_foreign_key "job_skills", "jobs"
  add_foreign_key "job_skills", "skills"
  add_foreign_key "jobs", "users", column: "client_id"
  add_foreign_key "messages", "conversations"
  add_foreign_key "messages", "users", column: "sender_id"
  add_foreign_key "milestones", "contracts"
  add_foreign_key "notifications", "users"
  add_foreign_key "reviews", "contracts"
  add_foreign_key "reviews", "users", column: "reviewed_user_id"
  add_foreign_key "reviews", "users", column: "reviewer_id"
  add_foreign_key "transactions", "milestones"
  add_foreign_key "transactions", "users", column: "client_id"
  add_foreign_key "user_skills", "skills"
  add_foreign_key "user_skills", "users"
end
