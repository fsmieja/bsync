class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.string :title
      t.text :content
      t.integer :basecamp_id
      t.integer :project_id
      t.text :author
      t.timestamp :posted_on
      t.timestamp :commented_on

      t.timestamps
    end
  end
end
