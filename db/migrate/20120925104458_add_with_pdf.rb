class AddWithPdf < ActiveRecord::Migration
  def change
    add_column :newsletters, :with_pdf, :boolean, :null => false, :default => false
    add_column :communications, :with_pdf, :boolean, :null => false, :default => false
  end
end
