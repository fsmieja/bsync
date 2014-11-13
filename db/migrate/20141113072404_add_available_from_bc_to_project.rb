class AddAvailableFromBcToProject < ActiveRecord::Migration
  def change
    add_column :projects, :available_messages, :integer, :default => 0
    add_column :projects, :available_tasks, :integer, :default => 0
    add_column :projects, :available_message_comments, :integer, :default => 0
    add_column :projects, :available_task_comments, :integer, :default => 0
  end
end
