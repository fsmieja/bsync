class CreateAuths < ActiveRecord::Migration
  def change
    create_table :auths do |t|
      t.string :token
      t.string :domain

      t.timestamps
    end
  end
end
