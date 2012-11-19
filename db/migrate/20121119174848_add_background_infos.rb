class AddBackgroundInfos < ActiveRecord::Migration
  def change
    create_table :shipments do |t|
      t.belongs_to :communication, :null => false
      t.string :description
      t.datetime :started_at
      t.datetime :stopped_at
      t.integer :dones, :null => false, :default => 0
      t.integer :total, :null => false, :default => 0
      t.string :state, :null => false
      t.text :report
      t.string   :mail_file_name
      t.integer  :mail_file_size
      t.string   :mail_content_type
      t.datetime :mail_updated_at
      t.timestamps
    end
    add_index :shipments, :communication_id

    create_table :sendings do |t|
      t.belongs_to :shipment, :null => false
      t.belongs_to :touchable
      t.string :canal
      t.text :coordinate
      t.datetime :sent_at
      t.text :report
      t.timestamps
    end
    add_index :sendings, :shipment_id
    add_index :sendings, :touchable_id

    add_column :untouchables, :search_key, :string
  end
end
