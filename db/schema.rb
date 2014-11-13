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

ActiveRecord::Schema.define(:version => 20141113144357) do

  create_table "attachments", :force => true do |t|
    t.integer  "basecamp_id"
    t.string   "filename"
    t.string   "basecamp_url"
    t.string   "author"
    t.string   "name"
    t.string   "attachment_type"
    t.integer  "comment_id"
    t.integer  "message_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comment_taggings", :force => true do |t|
    t.integer  "comment_id"
    t.integer  "tag_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comments", :force => true do |t|
    t.text     "content"
    t.string   "author"
    t.integer  "basecamp_id"
    t.datetime "posted_on"
    t.integer  "message_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "num_attachments"
    t.integer  "task_id"
  end

  create_table "comments_tags", :force => true do |t|
    t.integer  "comment_id"
    t.string   "tag_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "message_taggings", :force => true do |t|
    t.integer  "message_id"
    t.integer  "tag_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "messages", :force => true do |t|
    t.string   "title"
    t.text     "content"
    t.integer  "basecamp_id"
    t.integer  "project_id"
    t.text     "author"
    t.datetime "posted_on"
    t.datetime "commented_on"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "num_attachments", :default => 0
    t.integer  "num_comments"
  end

  create_table "messages_tags", :force => true do |t|
    t.integer  "message_id"
    t.string   "tag_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "projects", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "created_on"
    t.datetime "last_changed_on"
    t.string   "status"
    t.string   "company_name"
    t.integer  "basecamp_id"
    t.text     "announcement"
    t.text     "description"
    t.integer  "available_messages",         :default => 0
    t.integer  "available_tasks",            :default => 0
    t.integer  "available_message_comments", :default => 0
    t.integer  "available_task_comments",    :default => 0
  end

  create_table "tags", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "last_used_at"
  end

  create_table "tasks", :force => true do |t|
    t.datetime "start_on"
    t.datetime "complete_on"
    t.string   "owner"
    t.text     "content"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_id"
    t.integer  "num_comments"
    t.integer  "basecamp_id"
    t.string   "creator"
    t.boolean  "complete",     :default => false
  end

  create_table "words", :force => true do |t|
    t.string   "word"
    t.string   "word_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
