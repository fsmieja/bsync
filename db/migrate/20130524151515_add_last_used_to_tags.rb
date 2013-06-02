class AddLastUsedToTags < ActiveRecord::Migration
  def change
    add_column :tags, :last_used_at, :timestamp
  end
end
