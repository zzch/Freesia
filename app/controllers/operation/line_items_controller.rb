# -*- encoding : utf-8 -*-
class Operation::LineItemsController < Operation::BaseController
  before_action :find_line_item, only: %w(async_update_quantity async_update_started_at async_update_ended_at cancel finish)
  before_action :find_tab, only: %w(new_driving new_product new_course new_other create_driving create_product create_course create_other)

  def new_driving
    @form = Operation::CreateProductLineItem.new
  end

  def new_product
    @form = Operation::CreateProductLineItem.new
  end

  def new_course
    @form = Operation::CreateProductLineItem.new
  end

  def new_other
    @form = Operation::CreateOtherLineItem.new
  end

  def create_product
    @form = Operation::CreateProductLineItem.new(params[:operation_create_product_line_item])
    if @form.valid?
      begin
        LineItem.create_product(club: @current_club, tab: @tab, form: @form)
        redirect_to @tab, notice: '操作成功'
      rescue ProductNotFound
        @form.errors.add(:base, '找不到商品')
        render action: 'new_product'
      rescue InvalidProduct
        @form.errors.add(:base, '无效的商品')
        render action: 'new_product'
      end
    else
      render action: 'new_product'
    end
  end

  def create_other
    @form = Operation::CreateOtherLineItem.new(params[:operation_create_other_line_item])
    if @form.valid?
      LineItem.create_other(club: @current_club, tab: @tab, form: @form)
      redirect_to @tab, notice: '操作成功'
    else
      render action: 'new_other'
    end
  end

  def async_update_quantity
    if (0..99).include?(quantity = params[:quantity].to_i)
      @line_item.update_quantity(quantity)
      render json: JsonMessenger.new
    else
      render json: JsonMessenger.new('', false)
    end
  end

  def async_update_started_at
    begin
      @line_item.update_started_at(hour: params[:hour], minute: params[:minute])
      render json: JsonMessenger.new(actual_minutes: view_context.porto_minute(@line_item.actual_minutes))
    rescue InvalidTime
      render json: JsonMessenger.new('', false)
    end
  end

  def async_update_ended_at
    begin
      @line_item.update_ended_at(hour: params[:hour], minute: params[:minute])
      render json: JsonMessenger.new(actual_minutes: view_context.porto_minute(@line_item.actual_minutes))
    rescue InvalidTime
      render json: JsonMessenger.new('', false)
    end
  end
  
  def cancel
    @line_item.cancel
    redirect_to @line_item.tab, notice: '操作成功'
  end

  def finish
    @line_item.finish
    redirect_to @line_item.tab, notice: '操作成功'
  end

  protected
    def find_line_item
      @line_item = @current_club.line_items.find(params[:id])
    end

    def find_tab
      @tab = @current_club.tabs.find(params[:tab_id])
    end
end
