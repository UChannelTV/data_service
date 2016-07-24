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

ActiveRecord::Schema.define(version: 20160814035529) do

  create_table "filler_videos", force: :cascade do |t|
    t.string   "name",       limit: 255,                 null: false
    t.string   "source",     limit: 255,                 null: false
    t.integer  "duration",   limit: 4,                   null: false
    t.string   "video_url",  limit: 255
    t.boolean  "expired",                default: false
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  add_index "filler_videos", ["expired"], name: "index_filler_videos_on_expired", using: :btree
  add_index "filler_videos", ["name", "source"], name: "index_filler_videos_on_name_and_source", unique: true, using: :btree

  create_table "video_categories", force: :cascade do |t|
    t.string   "name",         limit: 255
    t.string   "english_name", limit: 255
    t.string   "qr_code",      limit: 255
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "video_categories", ["english_name"], name: "index_video_categories_on_english_name", unique: true, using: :btree
  add_index "video_categories", ["name"], name: "index_video_categories_on_name", unique: true, using: :btree

  create_table "video_statuses", force: :cascade do |t|
    t.string "status", limit: 255
  end

  create_table "video_uploads", force: :cascade do |t|
    t.integer  "video_id",   limit: 4
    t.string   "host",       limit: 255
    t.string   "host_id",    limit: 255
    t.boolean  "enabled"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "video_uploads", ["host", "host_id"], name: "index_video_uploads_on_host_and_host_id", unique: true, using: :btree
  add_index "video_uploads", ["video_id"], name: "index_video_uploads_on_video_id", using: :btree

  create_table "videos", force: :cascade do |t|
    t.integer  "duration",     limit: 4
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.string   "title",        limit: 255,               null: false
    t.text     "description",  limit: 65535
    t.string   "video_url",    limit: 255
    t.text     "tags",         limit: 65535
    t.string   "category_id",  limit: 255
    t.integer  "status_id",    limit: 4,     default: 1, null: false
    t.text     "other",        limit: 65535
    t.integer  "parent_video", limit: 4
    t.string   "thumbnail",    limit: 255
  end

  add_index "videos", ["category_id", "created_at"], name: "index_videos_on_category_id_and_created_at", using: :btree
  add_index "videos", ["created_at"], name: "index_videos_on_created_at", using: :btree
  add_index "videos", ["status_id"], name: "index_videos_on_status_id", using: :btree
  add_index "videos", ["title", "category_id"], name: "index_videos_on_title_and_category_id", unique: true, using: :btree

  create_table "youtube_uploads", id: false, force: :cascade do |t|
    t.string   "youtube_id",             limit: 255
    t.integer  "duration",               limit: 4
    t.datetime "published_at"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.string   "title",                  limit: 255
    t.text     "description",            limit: 65535
    t.string   "thumbnail_small",        limit: 255
    t.string   "thumbnail_medium",       limit: 255
    t.string   "thumbnail_large",        limit: 255
    t.text     "tags",                   limit: 65535
    t.string   "category_id",            limit: 255
    t.string   "live_broadcast_content", limit: 255
    t.string   "upload_status",          limit: 255
    t.string   "privacy_status",         limit: 255
    t.boolean  "embeddable"
  end

  add_index "youtube_uploads", ["published_at"], name: "index_youtube_uploads_on_published_at", using: :btree
  add_index "youtube_uploads", ["youtube_id"], name: "index_youtube_uploads_on_youtube_id", unique: true, using: :btree

end
