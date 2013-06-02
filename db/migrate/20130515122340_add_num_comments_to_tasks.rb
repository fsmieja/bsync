class AddNumCommentsToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :num_comments, :integer
  end
end
