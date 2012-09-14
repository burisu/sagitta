class AddCommunicationTitle < ActiveRecord::Migration
  def change
    add_column :communications, :title, :string
  end
end
