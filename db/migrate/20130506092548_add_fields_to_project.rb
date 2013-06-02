class AddFieldsToProject < ActiveRecord::Migration
  def change
    add_column :projects, :created_on, :timestamp
    add_column :projects, :last_changed_on, :timestamp
    add_column :projects, :status, :string
    add_column :projects, :company_name, :string
  end
end
