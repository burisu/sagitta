class CreateArticlesNewsletterRubrics < ActiveRecord::Migration
  def change
    create_table :articles_newsletter_rubrics, :id => false do |t|
      t.belongs_to :article
      t.belongs_to :newsletter_rubric
    end
    add_index :articles_newsletter_rubrics, :article_id
    add_index :articles_newsletter_rubrics, :newsletter_rubric_id

    add_column :articles, :readmore_label, :string
    add_column :articles, :logo_file_name, :string
    add_column :articles, :logo_file_size, :integer
    add_column :articles, :logo_content_type, :string
    add_column :articles, :logo_updated_at, :datetime
    add_column :articles, :logo_fingerprint, :string
  end
end
