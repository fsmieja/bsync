class AddCreatorToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :creator, :string
  end
end
