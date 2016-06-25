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

ActiveRecord::Schema.define(version: 20160623223518) do

  create_table "filler_videos", force: :cascade do |t|
    t.string   "name",       limit: 255,                 null: false
    t.string   "source",     limit: 255,                 null: false
    t.integer  "length",     limit: 4,                   null: false
    t.string   "video_url",  limit: 255
    t.boolean  "expired",                default: false
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  add_index "filler_videos", ["expired"], name: "index_filler_videos_on_expired", using: :btree
  add_index "filler_videos", ["name", "source"], name: "index_filler_videos_on_name_and_source", unique: true, using: :btree

end
