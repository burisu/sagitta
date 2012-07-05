class CreateCommunicationSystem < ActiveRecord::Migration
  def change
    create_table :communications do |t|
      t.belongs_to :client, :null => false
      t.string :name
      t.date :planned_on
      t.string :sender_label
      t.string :sender_email
      t.string :reply_to_email
      t.string :test_email
      # Textual message
      t.text :message
      # Image flyer
      t.string   :flyer_file_name
      t.integer  :flyer_file_size
      t.string   :flyer_content_type
      t.datetime :flyer_updated_at
      t.string   :flyer_fingerprint

      t.boolean :distributed, :null => false, :default => false
      t.datetime :distributed_at

      t.timestamps
      t.integer :lock_version, :null => false, :default => 0
    end
    add_index :communications, :client_id

    create_table :touchables do |t|
      t.belongs_to :communication, :null => false
      t.string :email, :null => false
      t.datetime :sent_at
      t.timestamps
    end
    add_index :touchables, :communication_id
    add_index :touchables, :email

    create_table :effects do |t|
      t.belongs_to :communication, :null => false
      t.belongs_to :touchable
      t.string :nature, :null => false
      t.datetime :made_at, :null => false
      t.timestamps
    end
    add_index :effects, :communication_id
    add_index :effects, :touchable_id
    
    create_table :untouchables do |t|
      t.belongs_to :client, :null => false
      t.string :email, :null => false
      t.boolean :destroyable, :null => false, :default => false
      t.datetime :unsubscribed_at
      t.timestamps
    end
    add_index :untouchables, :client_id
    add_index :untouchables, :email

  end
end
