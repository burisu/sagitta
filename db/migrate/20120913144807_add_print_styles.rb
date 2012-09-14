class AddPrintStyles < ActiveRecord::Migration
  def change
    add_column :newsletters, :print_style, :text
    add_column :newsletter_rubrics, :article_print_style, :text
  end
end
