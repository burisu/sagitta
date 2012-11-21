class AddDocumentToCommunication < ActiveRecord::Migration
  def up
    add_column :communications, :nature, :string
    execute "UPDATE communications SET nature = CASE WHEN newsletter_id IS NULL THEN 'flyer' ELSE 'newsletter' END"
    add_attachment :communications, :document

    add_column :shipments, :launcher_id, :integer

    add_column :communications, :ecofax_number, :string
    add_column :communications, :ecofax_password, :string

    add_column :users, :ecofax_number, :string
    add_column :users, :ecofax_password, :string
  end

  def down
    remove_column :users, :ecofax_password
    remove_column :users, :ecofax_number

    remove_column :communications, :ecofax_password
    remove_column :communications, :ecofax_number

    remove_column :shipments, :launcher_id

    remove_attachment :communications, :document
    remove_column     :communications, :nature
  end
end
