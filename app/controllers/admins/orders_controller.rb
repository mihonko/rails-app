class Admins::OrdersController < ApplicationController
  before_action :authenticate_admin! # 管理者ログイン必須
  before_action :set_q, only: [:index, :search]

  def index
    @orders = @q.result.page(params[:page]).per(10)
  end

  def search
    @results = @q.result.page(params[:page]).per(10)
  end

  def show
    @order = Order.find(params[:id])
    @total = @order.order_product.inject(0) { |sum, item| sum + item.sum_of_price }
  end

  private

  def set_q
    @q = Order.ransack(params[:q])
  end
end
