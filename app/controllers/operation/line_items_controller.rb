# -*- encoding : utf-8 -*-
class Operation::LineItemsController < Operation::BaseController
  before_action :find_line_item, only: %w(update_driving_pay_method update_non_driving_pay_method async_update_quantity async_increase_quantity_with_machine async_update_started_at async_update_ended_at cancel finish edit_bay update_bay)
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

  def update_driving_pay_method
    @tab = @line_item.tab
    @driving_form = Operation::UpdateDrivingLineItemPayMethod.new(params[:operation_update_driving_line_item_pay_method])
    if @driving_form.valid?
      @line_item.update_driving_pay_method(@driving_form)
      redirect_to checkout_tab_path(@tab), notice: '操作成功'
    else
      @non_driving_form = Operation::UpdateNonDrivingLineItemPayMethod.new
      render template: 'operation/tabs/checkout'
    end
  end

  def update_non_driving_pay_method
    @tab = @line_item.tab
    @non_driving_form = Operation::UpdateNonDrivingLineItemPayMethod.new(params[:operation_update_non_driving_line_item_pay_method])
    if @non_driving_form.valid?
      @line_item.update_non_driving_pay_method(@non_driving_form)
      redirect_to checkout_tab_path(@tab), notice: '操作成功'
    else
      @driving_form = Operation::UpdateDrivingLineItemPayMethod.new
      render template: 'operation/tabs/checkout'
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

  def async_increase_quantity_with_machine
    begin
      render json: JsonMessenger.new(quantity: @line_item.increase_quantity_with_machine)
    rescue MachineNotFound
      render json: JsonMessenger.new('设备不存在', false)
    rescue MachineOffline
      render json: JsonMessenger.new('设备处于离线状态', false)
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

  def edit_bay
  end

  def update_bay
    begin
      @line_item.swap_bay_with(@current_club.bays.find(params[:line_item][:bay_id]))
      redirect_to @line_item.tab, notice: '操作成功'
    rescue OccupiedBay
      redirect_to @line_item.tab, alert: '操作失败！打位状态无效！'
    end
  end

  protected
    def find_line_item
      @line_item = @current_club.line_items.find(params[:id])
    end

    def find_tab
      @tab = @current_club.tabs.find(params[:tab_id])
    end
end
