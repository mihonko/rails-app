class CartItem < ApplicationRecord
  belongs_to :user
  belongs_to :product

  def sum_of_price
    product.price * quantity
  end
end
