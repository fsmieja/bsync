class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :title
      t.timestamp :start_at
      t.integer :project_id
      t.string :creator
      t.timestamps
    end
  end
end
