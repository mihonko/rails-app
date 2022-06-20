class OrderProduct < ApplicationRecord
  belongs_to :order
  belongs_to :product

  def sum_of_price
    product.price * quantity
  end
end
