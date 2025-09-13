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

ActiveRecord::Schema[8.0].define(version: 2025_09_13_000738) do
  create_table "orders", force: :cascade do |t|
    t.string "external_id"
    t.string "status"
    t.decimal "total"
    t.text "data"
    t.boolean "synced"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["external_id"], name: "index_orders_on_external_id", unique: true
  end

  create_table "sync_logs", force: :cascade do |t|
    t.string "sync_type"
    t.string "status"
    t.integer "orders_processed"
    t.integer "orders_synced"
    t.text "error_details"
    t.datetime "started_at"
    t.datetime "completed_at"
    t.integer "duration"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end
end
