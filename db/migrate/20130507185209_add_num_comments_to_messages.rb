class AddNumCommentsToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :num_comments, :integer
  end
end
