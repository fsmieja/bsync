class AddAvailableEventsToProject < ActiveRecord::Migration
  def change
    add_column :projects, :available_events, :integer, :default => 0
  end
end
