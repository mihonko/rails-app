class CartsController < ApplicationController
  def cart
    @cart_items = CartItem.where(user_id: current_user.id)
    @total = @cart_items.inject(0) { |sum, item| sum + item.sum_of_price }
  end

  def add_item
    if user_signed_in?
      @cart_item = CartItem.new(user_id: current_user.id, product_id: params[:product_id], quantity: params[:quantity])
      @cart_item.save
    else
      # 未ログイン時はセッションに
    end
    redirect_to product_path(params[:product_id])
  end

  def update_item
    @cart_item = CartItem.find_by(user_id: current_user.id, product_id: params[:product_id])
    @cart_item.update(quantity: params[:quantity])
    redirect_to cart_path
  end

  def delete_item
    @cart_item = CartItem.find_by(user_id: current_user.id, product_id: params[:product_id])
    @cart_item.destroy
    # 遷移元取得
    @path = Rails.application.routes.recognize_path(request.referer)
    # 注文画面から来ていた場合は注文画面へリダイレクト
    if @path[:controller] == 'carts'
      redirect_to cart_path()
    else
      redirect_to product_path(params[:product_id])
    end
  end
end
