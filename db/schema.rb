# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20231217053531) do

  create_table "attendances", force: :cascade do |t|
    t.date "worked_on"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.string "note"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "manager_id"
    t.boolean "next_day"
    t.datetime "overtime_end_time"
    t.index ["user_id"], name: "index_attendances_on_user_id"
  end

  create_table "bases", force: :cascade do |t|
    t.string "name"
    t.string "location"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "base_number"
    t.string "base_type"
  end

  create_table "notifications", force: :cascade do |t|
    t.integer "user_id"
    t.integer "manager_id"
    t.integer "attendance_id"
    t.text "content"
    t.boolean "read"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_active", default: false, null: false
    t.string "status"
    t.datetime "approved_at"
    t.date "requested_month"
    t.string "source"
    t.text "note"
    t.time "scheduled_end"
    t.boolean "next_day"
    t.index ["attendance_id"], name: "index_notifications_on_attendance_id"
    t.index ["manager_id"], name: "index_notifications_on_manager_id"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.string "remember_digest"
    t.boolean "admin", default: false
    t.string "department"
    t.datetime "basic_time", default: "2023-12-23 23:00:00"
    t.datetime "work_time", default: "2023-12-23 22:30:00"
    t.boolean "manager", default: false
    t.string "employee_number"
    t.string "card_id"
    t.datetime "work_start_time"
    t.datetime "work_end_time"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

end
