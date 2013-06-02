class CreateMessageTaggings < ActiveRecord::Migration
  def change
    create_table :message_taggings do |t|
      t.integer :message_id
      t.integer :tag_id
      t.datetime :created_at

      t.timestamps
    end
  end
end
