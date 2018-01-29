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

ActiveRecord::Schema.define(version: 20180129042126) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "ucb_class_date", force: :cascade do |t|
    t.integer "ucb_class_id", null: false
    t.datetime "starts_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "ucb_class_histories", force: :cascade do |t|
    t.integer "ucb_class_id", null: false
    t.string "level", null: false
    t.datetime "starts_at", null: false
    t.datetime "ends_at", null: false
    t.string "teacher", null: false
    t.boolean "available"
    t.string "registration_url"
    t.integer "ucb_id", null: false
    t.string "human_dates"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "history_started_at", null: false
    t.datetime "history_ended_at"
    t.integer "history_user_id"
    t.index ["history_ended_at"], name: "index_ucb_class_histories_on_history_ended_at"
    t.index ["history_started_at"], name: "index_ucb_class_histories_on_history_started_at"
    t.index ["history_user_id"], name: "index_ucb_class_histories_on_history_user_id"
    t.index ["level"], name: "index_ucb_class_histories_on_level"
    t.index ["starts_at"], name: "index_ucb_class_histories_on_starts_at"
    t.index ["teacher"], name: "index_ucb_class_histories_on_teacher"
    t.index ["ucb_class_id"], name: "index_ucb_class_histories_on_ucb_class_id"
    t.index ["ucb_id"], name: "index_ucb_class_histories_on_ucb_id"
  end

  create_table "ucb_class_holds", force: :cascade do |t|
    t.integer "user_id"
    t.string "hold_url"
    t.integer "ucb_class_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "ucb_classes", force: :cascade do |t|
    t.string "level", null: false
    t.datetime "starts_at", null: false
    t.datetime "ends_at", null: false
    t.string "teacher", null: false
    t.boolean "available"
    t.string "registration_url"
    t.integer "ucb_id", null: false
    t.string "human_dates"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["level", "starts_at", "teacher"], name: "index_ucb_classes_on_level_and_starts_at_and_teacher"
    t.index ["ucb_id"], name: "index_ucb_classes_on_ucb_id"
  end

  create_table "user_ucb_class_match_histories", force: :cascade do |t|
    t.integer "user_ucb_class_match_id", null: false
    t.integer "user_id"
    t.integer "ucb_class_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "history_started_at", null: false
    t.datetime "history_ended_at"
    t.integer "history_user_id"
    t.index ["history_ended_at"], name: "index_user_ucb_class_match_histories_on_history_ended_at"
    t.index ["history_started_at"], name: "index_user_ucb_class_match_histories_on_history_started_at"
    t.index ["history_user_id"], name: "index_user_ucb_class_match_histories_on_history_user_id"
    t.index ["user_ucb_class_match_id"], name: "index_user_ucb_class_match_histories_on_user_ucb_class_match_id"
  end

  create_table "user_ucb_class_matches", force: :cascade do |t|
    t.integer "user_id"
    t.integer "ucb_class_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_ucb_preferences", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "class_name", null: false
    t.boolean "active"
    t.json "preferences"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "phone"
    t.string "ucb_password"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
