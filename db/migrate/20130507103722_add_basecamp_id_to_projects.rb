class AddBasecampIdToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :basecamp_id, :integer
  end
end
