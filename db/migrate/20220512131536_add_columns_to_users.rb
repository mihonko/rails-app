class AddColumnsToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :last_name, :string
    add_column :users, :first_name, :string
    add_column :users, :phone_number, :integer
    add_column :users, :postal_code, :integer
    add_column :users, :prefecture, :string
    add_column :users, :city, :string
    add_column :users, :address1, :string
    add_column :users, :address2, :string
  end
end
