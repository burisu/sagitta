class ChangeEffectReference < ActiveRecord::Migration
  def change
    rename_column :effects, :touchable_id, :sending_id
    add_column :effects, :shipment_id, :integer
    add_index :effects, :shipment_id
    add_column :sendings, :key, :string
    add_index :sendings, :key
    add_column :sendings, :communication_id, :integer
    add_index :sendings, :communication_id
  end
end
