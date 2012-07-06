class EnhanceCommunication < ActiveRecord::Migration
  def change
    add_column :communications, :subject, :string
    add_column :communications, :unsubscribe_label, :string
    add_column :communications, :unreadable_label, :string
    add_column :communications, :message_label, :string
    add_column :communications, :target_url, :string
  end
end
