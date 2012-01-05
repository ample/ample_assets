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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120105034123) do

  create_table "ample_assets_files", :force => true do |t|
    t.string   "keywords"
    t.string   "alt_text"
    t.string   "attachment_uid"
    t.string   "attachment_mime_type"
    t.string   "attachment_ext"
    t.string   "attachment_name"
    t.integer  "attachment_width"
    t.integer  "attachment_height"
    t.string   "attachment_gravity"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pages", :force => true do |t|
    t.string   "title"
    t.integer  "file_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
