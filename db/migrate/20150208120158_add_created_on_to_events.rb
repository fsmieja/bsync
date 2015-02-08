class AddCreatedOnToEvents < ActiveRecord::Migration
  def change
    add_column :events, :created_on, :timestamp
  end
end
