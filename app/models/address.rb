class Address < ApplicationRecord
  belongs_to :user

  validates :last_name, presence: true
  validates :first_name, presence: true
  validates :phone_number, presence: true, numericality: { only_integer: true}, format: { with: /\A\d{10,11}\z/ }
  validates :postal_code, presence: true, format: { with: /\A\d{7}\z/ }
  validates :prefecture, presence: true
  validates :city, presence: true
  validates :address1, presence: true
end
