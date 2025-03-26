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

ActiveRecord::Schema[8.0].define(version: 2025_03_15_093015) do
  create_table "addresses", force: :cascade do |t|
    t.string "zip"
    t.string "town"
    t.string "street"
    t.string "number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "courses", force: :cascade do |t|
    t.datetime "start_at"
    t.datetime "end_at"
    t.integer "week_day"
    t.integer "subject_id", null: false
    t.integer "moment_id", null: false
    t.integer "person_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "school_class_id", null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_courses_on_deleted_at"
    t.index ["moment_id"], name: "index_courses_on_moment_id"
    t.index ["person_id"], name: "index_courses_on_person_id"
    t.index ["school_class_id"], name: "index_courses_on_school_class_id"
    t.index ["subject_id"], name: "index_courses_on_subject_id"
  end

  create_table "examinations", force: :cascade do |t|
    t.string "title"
    t.datetime "expected_at"
    t.integer "course_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["course_id"], name: "index_examinations_on_course_id"
    t.index ["deleted_at"], name: "index_examinations_on_deleted_at"
  end

  create_table "grades", force: :cascade do |t|
    t.integer "value"
    t.datetime "expected_at"
    t.integer "examination_id", null: false
    t.integer "person_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_grades_on_deleted_at"
    t.index ["examination_id"], name: "index_grades_on_examination_id"
    t.index ["person_id"], name: "index_grades_on_person_id"
  end

  create_table "moments", force: :cascade do |t|
    t.string "uid"
    t.datetime "start_at"
    t.datetime "end_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.string "period_type"
    t.integer "year"
    t.integer "period_number"
    t.index ["deleted_at"], name: "index_moments_on_deleted_at"
    t.index ["period_type", "year", "period_number"], name: "index_moments_on_period_type_and_year_and_period_number", unique: true
  end

  create_table "people", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "username"
    t.string "firstname"
    t.string "lastname"
    t.string "phone_number"
    t.string "iban"
    t.integer "address_id"
    t.string "type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status_id", null: false
    t.datetime "deleted_at"
    t.index ["address_id"], name: "index_people_on_address_id"
    t.index ["deleted_at"], name: "index_people_on_deleted_at"
    t.index ["email"], name: "index_people_on_email", unique: true
    t.index ["reset_password_token"], name: "index_people_on_reset_password_token", unique: true
    t.index ["status_id"], name: "index_people_on_status_id"
  end

  create_table "rooms", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "school_classes", force: :cascade do |t|
    t.string "uid"
    t.string "name"
    t.integer "person_id", null: false
    t.integer "room_id", null: false
    t.integer "moment_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "section_id", null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_school_classes_on_deleted_at"
    t.index ["moment_id"], name: "index_school_classes_on_moment_id"
    t.index ["person_id"], name: "index_school_classes_on_person_id"
    t.index ["room_id"], name: "index_school_classes_on_room_id"
    t.index ["section_id"], name: "index_school_classes_on_section_id"
  end

  create_table "sections", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "statuses", force: :cascade do |t|
    t.string "slug"
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "students_follow_classes", force: :cascade do |t|
    t.integer "student_id", null: false
    t.integer "school_class_id", null: false
    t.index ["school_class_id"], name: "index_students_follow_classes_on_school_class_id"
    t.index ["student_id", "school_class_id"], name: "idx_on_student_id_school_class_id_eecdf1d700", unique: true
    t.index ["student_id"], name: "index_students_follow_classes_on_student_id"
  end

  create_table "subjects", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "courses", "moments"
  add_foreign_key "courses", "people"
  add_foreign_key "courses", "school_classes"
  add_foreign_key "courses", "subjects"
  add_foreign_key "examinations", "courses"
  add_foreign_key "grades", "examinations"
  add_foreign_key "grades", "people"
  add_foreign_key "people", "statuses"
  add_foreign_key "school_classes", "moments"
  add_foreign_key "school_classes", "people"
  add_foreign_key "school_classes", "rooms"
  add_foreign_key "school_classes", "sections"
  add_foreign_key "students_follow_classes", "people", column: "student_id"
  add_foreign_key "students_follow_classes", "school_classes"
end
