class CreateAttachments < ActiveRecord::Migration
  def change
    create_table :attachments do |t|
      t.integer :basecamp_id
      t.string :filename
      t.string :basecamp_url
      t.string :author
      t.string :name
      t.string :type
      t.integer :comment_id
      t.integer :message_id

      t.timestamps
    end
  end
end
