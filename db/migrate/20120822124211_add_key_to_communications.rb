class AddKeyToCommunications < ActiveRecord::Migration
  def change
    add_column :communications, :key, :string
    add_index :communications, :key
    add_column :touchables, :key, :string
    add_index :touchables, :key
    add_column :touchables, :test, :boolean, :null => false, :default => false
  end
end
