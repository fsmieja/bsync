class AddBasecampIdToEvents < ActiveRecord::Migration
  def change
    add_column :events, :basecamp_id, :integer
  end
end
