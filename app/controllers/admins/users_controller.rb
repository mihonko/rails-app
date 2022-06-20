class Admins::UsersController < ApplicationController
  before_action :authenticate_admin! # 管理者ログイン必須
  before_action :set_q, only: [:index, :search]

  def index
    @users = @q.result.page(params[:page]).per(10)
  end

  def search
    @results = @q.result.page(params[:page]).per(10)
  end

  def show
    @user = User.find(params[:id])
  end

  private

  def set_q
    @q = User.ransack(params[:q])
  end
end
