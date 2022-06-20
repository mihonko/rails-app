class FavoritesController < ApplicationController
  def list
    @favorites = Favorite.where(user_id: current_user.id)
  end

  def create
    @product_favorite = Favorite.new(user_id: current_user.id, product_id: params[:product_id])
    @product_favorite.save
    redirect_to product_path(params[:product_id])
  end

  def destroy
    # 遷移元取得
    @path = Rails.application.routes.recognize_path(request.referer)
    # 遷移元コントローラー名をセッションに入れる
    session[:previous_controller] = @path[:controller]

    @product_favorite = Favorite.find_by(user_id: current_user.id, product_id: params[:product_id])
    @product_favorite.destroy


    if session[:previous_controller] == 'favorites'
      redirect_to favorite_list_path
    else
      redirect_to product_path(params[:product_id])
    end
  end
end
