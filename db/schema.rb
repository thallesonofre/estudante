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

ActiveRecord::Schema[8.1].define(version: 2026_11_02_135830) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "access_requests", force: :cascade do |t|
    t.string "institution_name", null: false
    t.string "institution_type", null: false
    t.string "contact_name", null: false
    t.string "email", null: false
    t.string "phone"
    t.integer "requested_role", default: 2, null: false
    t.integer "status", default: 0, null: false
    t.text "message"
    t.string "generated_password"
    t.datetime "reviewed_at"
    t.bigint "reviewed_by_id"
    t.bigint "provisioned_user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_access_requests_on_email"
    t.index ["provisioned_user_id"], name: "index_access_requests_on_provisioned_user_id"
    t.index ["reviewed_by_id"], name: "index_access_requests_on_reviewed_by_id"
    t.index ["status"], name: "index_access_requests_on_status"
  end

  create_table "announcements", force: :cascade do |t|
    t.string "title", null: false
    t.text "content", null: false
    t.integer "priority", default: 0, null: false
    t.integer "audience", default: 0, null: false
    t.boolean "pinned", default: false, null: false
    t.bigint "author_id", null: false
    t.datetime "published_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_announcements_on_author_id"
  end

  create_table "assessments", force: :cascade do |t|
    t.bigint "student_id", null: false
    t.bigint "subject_id", null: false
    t.integer "bimester", null: false
    t.string "title", null: false
    t.string "category", default: "Prova", null: false
    t.decimal "score", precision: 5, scale: 2, default: "0.0", null: false
    t.decimal "max_score", precision: 5, scale: 2, default: "10.0", null: false
    t.date "evaluated_on", null: false
    t.text "feedback"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["student_id", "subject_id", "bimester"], name: "index_assessments_on_student_id_and_subject_id_and_bimester"
    t.index ["student_id"], name: "index_assessments_on_student_id"
    t.index ["subject_id"], name: "index_assessments_on_subject_id"
  end

  create_table "attendances", force: :cascade do |t|
    t.bigint "student_id", null: false
    t.bigint "subject_id", null: false
    t.date "attended_on", null: false
    t.integer "bimester", default: 1, null: false
    t.integer "status", default: 0, null: false
    t.string "lesson_topic"
    t.string "justification"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["student_id", "subject_id", "attended_on"], name: "index_attendances_on_student_id_and_subject_id_and_attended_on", unique: true
    t.index ["student_id"], name: "index_attendances_on_student_id"
    t.index ["subject_id"], name: "index_attendances_on_subject_id"
  end

  create_table "classrooms", force: :cascade do |t|
    t.string "name", null: false
    t.integer "academic_year", default: 2026, null: false
    t.string "shift", default: "Matutino", null: false
    t.string "room_number"
    t.string "grade_level", default: "Ensino Médio", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "enrollments", force: :cascade do |t|
    t.bigint "student_id", null: false
    t.bigint "classroom_id", null: false
    t.string "status", default: "Ativo", null: false
    t.date "enrolled_on", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["classroom_id"], name: "index_enrollments_on_classroom_id"
    t.index ["student_id", "classroom_id"], name: "index_enrollments_on_student_id_and_classroom_id", unique: true
    t.index ["student_id"], name: "index_enrollments_on_student_id"
  end

  create_table "subjects", force: :cascade do |t|
    t.string "name", null: false
    t.string "code", null: false
    t.integer "workload_hours", default: 80, null: false
    t.bigint "classroom_id", null: false
    t.bigint "teacher_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["classroom_id"], name: "index_subjects_on_classroom_id"
    t.index ["code"], name: "index_subjects_on_code", unique: true
    t.index ["teacher_id"], name: "index_subjects_on_teacher_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "name", default: "", null: false
    t.integer "role", default: 2, null: false
    t.string "registration_number"
    t.string "phone"
    t.string "department"
    t.string "job_title"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["registration_number"], name: "index_users_on_registration_number", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role"], name: "index_users_on_role"
  end

  add_foreign_key "access_requests", "users", column: "provisioned_user_id"
  add_foreign_key "access_requests", "users", column: "reviewed_by_id"
  add_foreign_key "announcements", "users", column: "author_id"
  add_foreign_key "assessments", "subjects"
  add_foreign_key "assessments", "users", column: "student_id"
  add_foreign_key "attendances", "subjects"
  add_foreign_key "attendances", "users", column: "student_id"
  add_foreign_key "enrollments", "classrooms"
  add_foreign_key "enrollments", "users", column: "student_id"
  add_foreign_key "subjects", "classrooms"
  add_foreign_key "subjects", "users", column: "teacher_id"
end
