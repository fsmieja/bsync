class AddAttachmentsToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :num_attachments, :integer, :default => 0
  end
end
