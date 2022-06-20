class CardsController < ApplicationController

  def list
    # @cards = Card.where(user_id: current_user.id)
    card = Card.find_by(user_id: current_user.id)
    if card.nil?
      @cards = nil
    else
      Payjp.api_key = ENV['PAYJP_SECRET_KEY']
      customer = Payjp::Customer.retrieve(card.customer_id)
      @cards = customer.cards.all()
    end
  end

  def form
    # 遷移元取得
    @path = Rails.application.routes.recognize_path(request.referer)
    # 遷移元コントローラー名をセッションに入れる
    session[:previous_controller] = @path[:controller]
    logger.error(session[:previous_controller])
  end

  def add_card
    Payjp.api_key = ENV['PAYJP_SECRET_KEY']
    card = Card.find_by(user_id: current_user.id)
    if card.nil?
      # 顧客未登録
      customer = Payjp::Customer.create(
        description: 'test',
        card: params[:token_id]
      )
      @card = Card.new(user_id: current_user.id, customer_id: customer.id, card_id: customer.default_card)
    else
      # 顧客登録済み
      customer = Payjp::Customer.retrieve(card.customer_id)
      new_card = customer.cards.create(
        card: params[:token_id]
      )
      @card = Card.new(user_id: current_user.id, customer_id: card.customer_id, card_id: new_card.id)
    end

    # respond_to do |format|
      if @card.save
        if session[:previous_controller] == 'orders'
          path = '/order'
        else
          path = '/card_list'
        end
        render json: {
          :path => path
        }
      else
        format.html
        format.json
      end
    # end
  end

  def delete_card
    card = Card.find_by(user_id: current_user.id)
    Payjp.api_key = ENV['PAYJP_SECRET_KEY']
    customer = Payjp::Customer.retrieve(card.customer_id)
    card = customer.cards.retrieve(params[:card_id])
    card.delete
    @card = Card.find_by(card_id: params[:card_id])
    @card.destroy
    redirect_to card_list_path()
  end

end
