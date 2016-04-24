# -*- encoding : utf-8 -*-
class Operation::ProductCategoriesController < Operation::BaseController
  before_action :find_product_category, only: %w(show edit update destroy)
  
  def index
    @product_categories = @current_club.product_categories.page(params[:page])
  end
  
  def show
  end
  
  def new
    @product_category = ProductCategory.new
  end
  
  def edit
  end
  
  def create
    @product_category = @current_club.product_categories.new(product_category_params)
    if @product_category.save
      redirect_to @product_category, notice: '操作成功'
    else
      render action: 'new'
    end
  end
  
  def update
    if @product_category.update(product_category_params)
      redirect_to @product_category, notice: '操作成功'
    else
      render action: 'edit'
    end
  end

  protected
    def product_category_params
      params.require(:product_category).permit!
    end

    def find_product_category
      @product_category = @current_club.product_categories.find(params[:id])
    end
end