class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.timestamp :start_on
      t.timestamp :complete_on
      t.string :owner
      t.text :content
      t.string :status

      t.timestamps
    end
  end
end
