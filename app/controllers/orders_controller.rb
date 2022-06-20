class OrdersController < ApplicationController
  before_action :authenticate_user!

  def list
    @orders = Order.includes(:order_product).where(user_id: current_user.id).order(id: "DESC")
  end
  def history
    @order = Order.find_by(id: params[:id])
    @total = @order.order_product.inject(0) { |sum, item| sum + item.sum_of_price }
    # クレジットカード
    card = Card.find_by(card_id: @order.card_id)
    if card.nil?
      @card = nil
      return
    end
    Payjp.api_key = ENV['PAYJP_SECRET_KEY']
    customer = Payjp::Customer.retrieve(card.customer_id)
    @card = customer.cards.retrieve(@order.card_id)
  end

  def order
    @user = current_user
    # 送付先
    @addresses = Address.where(user_id: current_user.id)
    # クレジットカード
    card = Card.find_by(user_id: current_user.id)
    if card.nil?
      @cards = nil
    else
      Payjp.api_key = ENV['PAYJP_SECRET_KEY']
      customer = Payjp::Customer.retrieve(card.customer_id)
      @cards = customer.cards.all()
    end
  end

  def confirm
    error = false
    # 選択チェック
    if params[:address_id].blank?
      flash[:address] = "送付先を選択してください"
      error = true
    end
    if params[:card_id].blank?
      flash[:card] = "クレジットカードを選択してください"
      error = true
    end
    if error
      redirect_to order_path
      return
    end
    @cart_items = CartItem.where(user_id: current_user.id)
    @total = @cart_items.inject(0) { |sum, item| sum + item.sum_of_price }

    @user = current_user
    # 送付先
    @address = Address.find_by(id: params[:address_id])
    # クレジットカード
    card = Card.find_by(card_id: params[:card_id])
    customer = Payjp::Customer.retrieve(card.customer_id)
    @card = customer.cards.first

    session[:address_id] = params[:address_id]
    session[:card_id] = params[:card_id]
    session[:cart_items] = @cart_items
  end

  def complete
    if session[:address_id].to_i > 0
      @address = Address.find_by(id: session[:address_id])
    else
      @address = current_user
    end

    # 在庫
    session[:cart_items].each do |cart_item|
      @product = Product.find(cart_item["product_id"])
      if @product.stock < cart_item["quantity"]
        flash[:out_of_stock] = "在庫が不足している商品があります。個数を選択し直してください。"
        redirect_to cart_path
      end
    end
    # トランザクション
    ActiveRecord::Base.transaction do
      # 合計金額
      @cart_items = CartItem.where(user_id: current_user.id)
      @total = @cart_items.inject(0) { |sum, item| sum + item.sum_of_price }
      # 顧客ID
      card = Card.find_by(user_id: current_user.id)
      # クレジットカード決済
      Payjp.api_key = ENV['PAYJP_SECRET_KEY']
      charge = Payjp::Charge.create(
        :amount => @total,
        :customer => card.customer_id,
        :card => session[:card_id],
        :currency => 'jpy',
      )
      @order = Order.new(
        user_id: current_user.id,
        last_name: @address.last_name,
        first_name: @address.first_name,
        phone_number: @address.phone_number,
        postal_code: @address.postal_code,
        prefecture: @address.prefecture,
        city: @address.city,
        address1: @address.address1,
        address2: @address.address2,
        card_id: session[:card_id]
      )
      @order.save

      session[:cart_items].each do |cart_item|
        @product = Product.find(cart_item["product_id"])
        @order_products = OrderProduct.new(
          order_id: @order.id,
          product_id: cart_item["product_id"],
          price: @product.price,
          quantity: cart_item["quantity"]
        )
        @order_products.save
        # 在庫を減らす
        @product = Product.find(cart_item["product_id"])
        res = @product.stock - cart_item["quantity"]
        @product.update(stock: res)
        @product.save
        # カートから削除
        @cart_item = CartItem.find(cart_item["id"])
        @cart_item.destroy
      end

      # セッション削除
      session.delete(:address_id)
      session.delete(:card_id)
      session.delete(:cart_items)
    end

  end

end
