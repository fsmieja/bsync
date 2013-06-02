class CreateCommentTaggings < ActiveRecord::Migration
  def change
    create_table :comment_taggings do |t|
      t.integer :comment_id
      t.integer :tag_id
      t.datetime :created_at

      t.timestamps
    end
  end
end
