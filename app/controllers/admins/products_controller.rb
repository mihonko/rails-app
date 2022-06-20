class Admins::ProductsController < ApplicationController
  before_action :authenticate_admin! # 管理者ログイン必須
  before_action :set_product, only: %i[ show edit update destroy ]
  before_action :set_q, only: [:index, :search]

  # GET /products or /products.json
  def index
    @products = @q.result.page(params[:page]).per(10)
  end

  def search
    @results = @q.result.page(params[:page]).per(10)
  end

  # GET /products/1 or /products/1.json
  def show
  end

  # GET /products/new
  def new
    @product = Product.new
  end

  # GET /products/1/edit
  def edit
  end

  # POST /products or /products.json
  def create
    @product = Product.new(product_params)

    respond_to do |format|
      if @product.save
          format.html { redirect_to admins_product_url(@product), notice: "商品を登録しました。" }
        format.json { render :show, status: :created, location: @product }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /products/1 or /products/1.json
  def update
    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to admins_product_url(@product), notice: "商品を更新しました。" }
        format.json { render :show, status: :ok, location: @product }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1 or /products/1.json
  def destroy
    @product.destroy

    respond_to do |format|
      format.html { redirect_to admins_products_url, notice: "商品を削除しました。" }
      format.json { head :no_content }
    end
  end


  private

    def product_params
      params.require(:product).permit(:name, :detail, :price, :image, :remove_image, :stock)
    end

    def set_product
      @product = Product.find(params[:id])
    end

    def set_q
      @q = Product.ransack(params[:q])
    end

end
