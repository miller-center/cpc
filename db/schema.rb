# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20180518000650) do

  create_table "Collections_Presidents", id: false, force: true do |t|
    t.integer "collection_id", null: false
    t.integer "president_id",  null: false
  end

  add_index "Collections_Presidents", ["collection_id", "president_id"], name: "index_Collections_Presidents_on_collection_id_and_president_id"
  add_index "Collections_Presidents", ["president_id", "collection_id"], name: "index_Collections_Presidents_on_president_id_and_collection_id"

  create_table "bookmarks", force: true do |t|
    t.integer  "user_id",       null: false
    t.string   "user_type"
    t.string   "document_id"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "document_type"
  end

  add_index "bookmarks", ["user_id"], name: "index_bookmarks_on_user_id"

  create_table "collections", force: true do |t|
    t.string   "name"
    t.string   "description"
    t.string   "size"
    t.string   "precisesize"
    t.boolean  "allpres"
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "collections", ["organization_id"], name: "index_collections_on_organization_id"

  create_table "organizations", force: true do |t|
    t.string   "name"
    t.string   "address"
    t.float    "latitude"
    t.float    "longitude"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
    t.text     "contact_info"
    t.text     "onboarding"
    t.text     "notes_dates"
    t.string   "notes_text"
    t.text     "update_period"
    t.text     "api_known"
    t.text     "api_url"
  end

  create_table "presidents", force: true do |t|
    t.string   "title"
    t.string   "fullname"
    t.string   "lastname"
    t.datetime "birthdate"
    t.datetime "deathdate"
    t.string   "birthplace"
    t.string   "deathplace"
    t.string   "education"
    t.string   "religion"
    t.string   "career"
    t.string   "party"
    t.string   "nicknames"
    t.string   "marriage"
    t.string   "children"
    t.datetime "inaugurationdate"
    t.integer  "number"
    t.string   "writings"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "enddate"
  end

  create_table "searches", force: true do |t|
    t.text     "query_params"
    t.integer  "user_id"
    t.string   "user_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "searches", ["user_id"], name: "index_searches_on_user_id"

  create_table "users", force: true do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "guest",                  default: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

end
