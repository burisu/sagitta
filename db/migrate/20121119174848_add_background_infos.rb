class AddBackgroundInfos < ActiveRecord::Migration
  def up
    add_column :communication, :sending, :boolean, :null => false, :default => false
    add_column :communication, :sending_total, :integer
    add_column :communication, :sending_count, :integer

    create_table :sendings do |t|
      t.belongs_to :communication
      t.datetime :started_at
      t.datetime :stopped_at
      t.text :report
    end

    create_table :sending_touchables do |t|
      t.belongs_to :sending
      t.belongs_to :touchable
      t.datetime :sent_at
    end

    add_column :untouchables, :search_key, :string
  end

  def down
  end
end
