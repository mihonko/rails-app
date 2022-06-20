class AddressesController < ApplicationController

  def list
    @addresses = Address.where(user_id: current_user.id)
  end

  def form
    @address = Address.new
    # 遷移元取得
    @path = Rails.application.routes.recognize_path(request.referer)
    # 遷移元コントローラー名をセッションに入れる
    session[:previous_controller] = @path[:controller]
  end

  def add_address
    @address = Address.new(user_id: current_user.id, last_name: params[:last_name], first_name: params[:first_name], phone_number: params[:phone_number], postal_code: params[:postal_code], prefecture: params[:prefecture], city: params[:city], address1: params[:address1], address2: params[:address2])

    if @address.save
      # 注文画面から来ていた場合は注文画面へリダイレクト
      if session[:previous_controller] == 'orders'
        redirect_to order_path()
      else
        redirect_to address_list_path()
      end
    else
      render "form"
    end

  end

  def delete_address
    @address = Address.find(params[:address_id])
    @address.destroy
    redirect_to address_list_path()
  end
end
