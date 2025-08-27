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

ActiveRecord::Schema[7.1].define(version: 2025_08_27_162518) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "cleanings", force: :cascade do |t|
    t.bigint "stroller_id", null: false
    t.bigint "cleaned_by_id", null: false
    t.string "cleaning_type"
    t.text "notes"
    t.datetime "next_due"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "cleaned_at"
    t.index ["cleaned_by_id"], name: "index_cleanings_on_cleaned_by_id"
    t.index ["stroller_id"], name: "index_cleanings_on_stroller_id"
  end

  create_table "maintenances", force: :cascade do |t|
    t.bigint "stroller_id", null: false
    t.bigint "reported_by_id", null: false
    t.text "issue_description"
    t.string "status"
    t.datetime "resolved_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["reported_by_id"], name: "index_maintenances_on_reported_by_id"
    t.index ["stroller_id"], name: "index_maintenances_on_stroller_id"
  end

  create_table "payments", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "ride_id", null: false
    t.decimal "amount"
    t.string "payment_method"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ride_id"], name: "index_payments_on_ride_id"
    t.index ["user_id"], name: "index_payments_on_user_id"
  end

  create_table "rides", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "stroller_id", null: false
    t.datetime "start_time"
    t.datetime "end_time"
    t.decimal "start_lat"
    t.decimal "start_lng"
    t.decimal "end_lat"
    t.decimal "end_lng"
    t.decimal "cost"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["stroller_id"], name: "index_rides_on_stroller_id"
    t.index ["user_id"], name: "index_rides_on_user_id"
  end

  create_table "stations", force: :cascade do |t|
    t.string "name"
    t.decimal "gps_lat"
    t.decimal "gps_lng"
    t.integer "capacity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "strollers", force: :cascade do |t|
    t.string "qr_code"
    t.decimal "gps_lat"
    t.decimal "gps_lng"
    t.integer "battery_level"
    t.string "status"
    t.bigint "station_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["station_id"], name: "index_strollers_on_station_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "full_name"
    t.string "phone_number"
    t.boolean "is_active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "phone"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "cleanings", "strollers"
  add_foreign_key "cleanings", "users", column: "cleaned_by_id"
  add_foreign_key "maintenances", "strollers"
  add_foreign_key "maintenances", "users", column: "reported_by_id"
  add_foreign_key "payments", "rides"
  add_foreign_key "payments", "users"
  add_foreign_key "rides", "strollers"
  add_foreign_key "rides", "users"
  add_foreign_key "strollers", "stations"
end
