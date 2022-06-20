class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
         # :recoverable, :rememberable # deviseのバリデーションは使わない

  attr_accessor :current_password

  # dependent: :destroy は、親のレコードを削除した際に関連する子のレコードも全て削除するための記述
  has_many :favorites, dependent: :destroy
  has_many :cart_items, dependent: :destroy


  # 編集時のみの項目
  validates :last_name, presence: true
  validates :first_name, presence: true
  validates :phone_number, presence: true, numericality: { only_integer: true}, format: { with: /\A\d{10,11}\z/ }
  validates :postal_code, presence: true, format: { with: /\A\d{7}\z/ }
  validates :prefecture, presence: true
  validates :city, presence: true
  validates :address1, presence: true
end
