class AddNewsletters < ActiveRecord::Migration
  def change
    create_table :newsletters do |t|
      t.belongs_to :client, :null => false
      t.string   :name,     :null => false
      t.string   :ecofax_number
      t.string   :ecofax_password
      t.string   :header_file_name
      t.integer  :header_file_size
      t.string   :header_content_type
      t.datetime :header_updated_at
      t.string   :header_fingerprint
      t.text     :introduction
      t.text     :conclusion
      t.text     :footer
      t.text     :global_style
    end
    add_index :newsletters, :client_id

    create_table :newsletter_rubrics do |t|
      t.belongs_to :newsletter, :null => false
      t.string     :name,       :null => false
      t.text       :article_style
    end
    add_index :newsletter_rubrics, :newsletter_id

    create_table :articles do |t|
      t.belongs_to :communication, :null => false
      t.belongs_to :newsletter,    :null => false
      t.belongs_to :rubric
      t.integer    :position
      t.string     :title
      t.text       :content
      t.string     :readmore_url
    end
    add_index :articles, :communication_id
    add_index :articles, :newsletter_id
    add_index :articles, :rubric_id

    create_table :pieces do |t|
      t.belongs_to :communication, :null => false
      t.belongs_to :article
      t.string   :name
      t.string   :document_file_name
      t.integer  :document_file_size
      t.string   :document_content_type
      t.datetime :document_updated_at
      t.string   :document_fingerprint
    end
    add_index :pieces, :communication_id
    add_index :pieces, :article_id

    add_column :communications, :introduction, :text
    add_column :communications, :conclusion, :text
    add_column :communications, :newsletter_id, :integer

    add_column :touchables, :fax, :string
  end
end
