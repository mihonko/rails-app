class CreateAddresses < ActiveRecord::Migration[7.0]
  def change
    create_table :addresses do |t|
      t.references :user, null: false, foreign_key: true
      t.string :last_name
      t.string :first_name
      t.string :phone_number
      t.string :postal_code
      t.string :prefecture
      t.string :city
      t.string :address1
      t.string :address2

      t.timestamps
    end
  end
end
