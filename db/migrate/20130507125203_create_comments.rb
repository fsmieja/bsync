class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.text :content
      t.string :author
      t.integer :basecamp_id
      t.timestamp :posted_on
      t.integer :message_id

      t.timestamps
    end
  end
end
