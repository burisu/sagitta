class UnifyCanals < ActiveRecord::Migration
  def up
    add_column :touchables, :coordinate, :text
    add_column :touchables, :canal, :string
    add_column :touchables, :search_key, :text
    add_index :touchables, :search_key
    execute "UPDATE touchables SET canal = 'email', coordinate = email, fax = NULL WHERE LENGTH(TRIM(email)) > 0"
    execute "UPDATE touchables SET canal = 'fax', coordinate = fax WHERE LENGTH(TRIM(fax)) > 0"
    execute "UPDATE touchables SET search_key = canal || '/' || LOWER(TRIM(coordinate))"
    remove_column :touchables, :email
    remove_column :touchables, :fax

    add_column :untouchables, :coordinate, :text
    add_column :untouchables, :canal, :string
    execute "UPDATE untouchables SET canal = 'email', coordinate = email WHERE LENGTH(TRIM(email)) > 0"
    remove_column :untouchables, :email

    add_column :users, :costs, :string
    add_column :users, :canals_priority, :string
  end

  def down
    remove_column :users, :canals_priority
    remove_column :users, :costs

    add_column :untouchables, :email, :string
    execute "UPDATE untouchables SET email = coordinate, canal = NULL WHERE canal = 'email'"
    execute "DELETE FROM untouchables WHERE canal IS NOT NULL"
    remove_column :untouchables, :canal
    remove_column :untouchables, :coordinate

    add_column :touchables, :fax, :string
    add_column :touchables, :email, :string
    execute "UPDATE touchables SET fax = coordinate, canal = NULL WHERE canal = 'fax'"
    execute "UPDATE touchables SET email = coordinate, canal = NULL WHERE canal = 'email'"
    execute "DELETE FROM touchables WHERE canal IS NOT NULL"
    remove_column :touchables, :search_key
    remove_column :touchables, :canal
    remove_column :touchables, :coordinate
  end
end
