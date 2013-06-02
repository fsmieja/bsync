class AddAttachmentsToComments < ActiveRecord::Migration
  def change
    add_column :comments, :num_attachments, :integer
  end
end
