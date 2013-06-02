class AddBasecampIdToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :basecamp_id, :integer
  end
end
