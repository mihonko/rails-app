class TopController < ApplicationController
  before_action :set_q

  def index
    @products = @q.result.page(params[:page]).per(10)
  end

  private
  
  def set_q
    @q = Product.ransack(params[:q])
  end
end
