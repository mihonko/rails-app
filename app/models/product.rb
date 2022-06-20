class Product < ApplicationRecord

  has_many :favorites, dependent: :destroy
  has_many :cart_items, dependent: :destroy

  mount_uploader :image, ImagesUploader

  def favorited?(user)
     favorites.where(user_id: user.id).exists?
  end

  def inTheCart?(user)
     cart_items.where(user_id: user.id).exists?
  end

  validates :name, presence: true
  validates :detail, presence: true
  validates :price, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0}
  validates :stock, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0}
end
