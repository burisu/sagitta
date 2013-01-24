class AddMarginsToNewsletter < ActiveRecord::Migration
  def change
    add_column :newsletters, :page_margins, :string
  end
end
