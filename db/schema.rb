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

ActiveRecord::Schema.define(:version => 20121119173410) do

  create_table "articles", :force => true do |t|
    t.integer  "communication_id",  :null => false
    t.integer  "newsletter_id",     :null => false
    t.integer  "rubric_id"
    t.integer  "position"
    t.string   "title"
    t.text     "content"
    t.string   "readmore_url"
    t.string   "readmore_label"
    t.string   "logo_file_name"
    t.integer  "logo_file_size"
    t.string   "logo_content_type"
    t.datetime "logo_updated_at"
    t.string   "logo_fingerprint"
  end

  add_index "articles", ["communication_id"], :name => "index_articles_on_communication_id"
  add_index "articles", ["newsletter_id"], :name => "index_articles_on_newsletter_id"
  add_index "articles", ["rubric_id"], :name => "index_articles_on_rubric_id"

  create_table "articles_newsletter_rubrics", :id => false, :force => true do |t|
    t.integer "article_id"
    t.integer "newsletter_rubric_id"
  end

  add_index "articles_newsletter_rubrics", ["article_id"], :name => "index_articles_newsletter_rubrics_on_article_id"
  add_index "articles_newsletter_rubrics", ["newsletter_rubric_id"], :name => "index_articles_newsletter_rubrics_on_newsletter_rubric_id"

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
    t.string   "key"
    t.text     "introduction"
    t.text     "conclusion"
    t.integer  "newsletter_id"
    t.string   "title"
    t.boolean  "with_pdf",           :default => false, :null => false
  end

  add_index "communications", ["client_id"], :name => "index_communications_on_client_id"
  add_index "communications", ["key"], :name => "index_communications_on_key"

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

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

  create_table "newsletter_rubrics", :force => true do |t|
    t.integer "newsletter_id",       :null => false
    t.string  "name",                :null => false
    t.text    "article_style"
    t.text    "article_print_style"
  end

  add_index "newsletter_rubrics", ["newsletter_id"], :name => "index_newsletter_rubrics_on_newsletter_id"

  create_table "newsletters", :force => true do |t|
    t.integer  "client_id",                              :null => false
    t.string   "name",                                   :null => false
    t.string   "ecofax_number"
    t.string   "ecofax_password"
    t.string   "header_file_name"
    t.integer  "header_file_size"
    t.string   "header_content_type"
    t.datetime "header_updated_at"
    t.string   "header_fingerprint"
    t.text     "introduction"
    t.text     "conclusion"
    t.text     "footer"
    t.text     "global_style"
    t.text     "print_style"
    t.boolean  "with_pdf",            :default => false, :null => false
  end

  add_index "newsletters", ["client_id"], :name => "index_newsletters_on_client_id"

  create_table "pieces", :force => true do |t|
    t.integer  "communication_id",      :null => false
    t.integer  "article_id"
    t.string   "name"
    t.string   "document_file_name"
    t.integer  "document_file_size"
    t.string   "document_content_type"
    t.datetime "document_updated_at"
    t.string   "document_fingerprint"
  end

  add_index "pieces", ["article_id"], :name => "index_pieces_on_article_id"
  add_index "pieces", ["communication_id"], :name => "index_pieces_on_communication_id"

  create_table "touchables", :force => true do |t|
    t.integer  "communication_id",                    :null => false
    t.datetime "sent_at"
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
    t.string   "key"
    t.boolean  "test",             :default => false, :null => false
    t.text     "coordinate"
    t.string   "canal"
    t.text     "search_key"
  end

  add_index "touchables", ["communication_id"], :name => "index_touchables_on_communication_id"
  add_index "touchables", ["key"], :name => "index_touchables_on_key"
  add_index "touchables", ["search_key"], :name => "index_touchables_on_search_key"

  create_table "untouchables", :force => true do |t|
    t.integer  "client_id",                          :null => false
    t.boolean  "destroyable",     :default => false, :null => false
    t.datetime "unsubscribed_at"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.text     "coordinate"
    t.string   "canal"
  end

  add_index "untouchables", ["client_id"], :name => "index_untouchables_on_client_id"

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
    t.string   "costs"
    t.string   "canals_priority"
  end

  add_index "users", ["authentication_token"], :name => "index_users_on_authentication_token", :unique => true
  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["unlock_token"], :name => "index_users_on_unlock_token", :unique => true

end
