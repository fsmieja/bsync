class CreateJoiningTablesTagsCommentsMessages < ActiveRecord::Migration
  def change
    create_table :comments_tags do |t|
      t.integer :comment_id
      t.string  :tag_id
      t.timestamps
    end

    create_table :messages_tags do |t|
      t.integer :message_id
      t.string  :tag_id
      t.timestamps
    end
  end

end
