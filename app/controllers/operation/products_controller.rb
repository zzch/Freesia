# -*- encoding : utf-8 -*-
class Operation::ProductsController < Operation::BaseController
  before_action :find_product, only: %w(show edit update destroy)
  
  def index
    @products = @current_club.products.page(params[:page])
  end
  
  def show
  end
  
  def new
    @product = Product.new
  end
  
  def edit
  end
  
  def create
    @product = @current_club.products.new(product_params)
    if @product.save
      redirect_to @product, notice: '操作成功'
    else
      render action: 'new'
    end
  end
  
  def update
    if @product.update(product_params)
      redirect_to @product, notice: '操作成功'
    else
      render action: 'edit'
    end
  end

  protected
    def product_params
      params.require(:product).permit!
    end

    def find_product
      @product = @current_club.products.find(params[:id])
    end
end