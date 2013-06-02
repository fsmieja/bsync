class AddAnnouncementToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :announcement, :text
  end
end
