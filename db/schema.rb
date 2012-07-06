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

ActiveRecord::Schema.define(:version => 20120706122118) do

  create_table "communications", :force => true do |t|
    t.integer  "client_id",                             :null => false
    t.string   "name"
    t.date     "planned_on"
    t.string   "sender_label"
    t.string   "sender_email"
    t.string   "reply_to_email"
    t.string   "test_email"
    t.text     "message"
    t.string   "flyer_file_name"
    t.integer  "flyer_file_size"
    t.string   "flyer_content_type"
    t.datetime "flyer_updated_at"
    t.string   "flyer_fingerprint"
    t.boolean  "distributed",        :default => false, :null => false
    t.datetime "distributed_at"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
    t.integer  "lock_version",       :default => 0,     :null => false
    t.string   "subject"
    t.string   "unsubscribe_label"
    t.string   "unreadable_label"
    t.string   "message_label"
    t.string   "target_url"
  end

  add_index "communications", ["client_id"], :name => "index_communications_on_client_id"

  create_table "effects", :force => true do |t|
    t.integer  "communication_id", :null => false
    t.integer  "touchable_id"
    t.string   "nature",           :null => false
    t.datetime "made_at",          :null => false
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "effects", ["communication_id"], :name => "index_effects_on_communication_id"
  add_index "effects", ["touchable_id"], :name => "index_effects_on_touchable_id"

  create_table "touchables", :force => true do |t|
    t.integer  "communication_id", :null => false
    t.string   "email",            :null => false
    t.datetime "sent_at"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "touchables", ["communication_id"], :name => "index_touchables_on_communication_id"
  add_index "touchables", ["email"], :name => "index_touchables_on_email"

  create_table "untouchables", :force => true do |t|
    t.integer  "client_id",                          :null => false
    t.string   "email",                              :null => false
    t.boolean  "destroyable",     :default => false, :null => false
    t.datetime "unsubscribed_at"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
  end

  add_index "untouchables", ["client_id"], :name => "index_untouchables_on_client_id"
  add_index "untouchables", ["email"], :name => "index_untouchables_on_email"

  create_table "users", :force => true do |t|
    t.string   "full_name"
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",        :default => 0
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.string   "authentication_token"
    t.boolean  "administrator"
    t.integer  "communications_quota",   :default => 0,  :null => false
    t.integer  "communications_count",   :default => 0,  :null => false
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "users", ["authentication_token"], :name => "index_users_on_authentication_token", :unique => true
  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["unlock_token"], :name => "index_users_on_unlock_token", :unique => true

end
