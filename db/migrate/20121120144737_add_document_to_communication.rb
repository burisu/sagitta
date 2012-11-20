class AddDocumentToCommunication < ActiveRecord::Migration
  def up
    add_column :communications, :nature, :string
    execute "UPDATE communications SET nature = CASE WHEN newsletter_id IS NULL THEN 'flyer' ELSE 'newsletter' END"
    add_attachment :communications, :document

    add_column :shipments, :launcher_id, :integer
  end

  def down
    remove_column :shipments, :launcher_id

    remove_attachment :communications, :document
    remove_column     :communications, :nature
  end
end
