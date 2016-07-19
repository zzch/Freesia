# -*- encoding : utf-8 -*-
class Operation::TabsController < Operation::BaseController
  before_action :find_tab, only: %w(show checkout check trash_confirmation trash cancel_confirmation cancel)
  
  def show
    if @tab.progressing?
      render 'progressing_show'
    else
      render 'show'
    end
  end

  def checkout
    if @tab.progressing? and @tab.ready_to_cast_accounts?
      @driving_form = Operation::UpdateDrivingLineItemPayMethod.new
      @non_driving_form = Operation::UpdateNonDrivingLineItemPayMethod.new
    else
      redirect_to @tab
    end
  end

  def check
    begin
      @tab.check
      redirect_to @tab, notice: '操作成功'
    rescue NotReadyToCheck
      redirect_to checkout_tab_path(@tab), alert: '操作失败！存在未确认的消费条目'
    rescue InvalidState
      redirect_to checkout_tab_path(@tab), alert: '操作失败！无效的消费单状态！'
    rescue InsufficientBalance
      redirect_to checkout_tab_path(@tab), alert: '操作失败！卡余额不足！'
    end
  end
  
  def new
    @member_form = Operation::MemberSetUpTab.new
    @visitor_form = Operation::VisitorSetUpTab.new
  end
  
  def member_set_up
    @form = Operation::MemberSetUpTab.new(params[:operation_member_set_up_tab])
    if @form.valid?
      @tab = Tab.set_up_as_member(club: @current_club, form: @form)
      redirect_to @tab, notice: '操作成功'
    else
      redirect_to new_tab_path(bay_ids: params[:operation_member_set_up_tab][:bay_ids]), alert: '操作失败，未选择会员'
    end
  end

  def visitor_set_up
    @form = Operation::VisitorSetUpTab.new(params[:operation_visitor_set_up_tab])
    if @form.valid?
      @tab = Tab.set_up_as_visitor(club: @current_club, form: @form)
      redirect_to @tab, notice: '操作成功'
    else
      render action: 'new'
    end
  end

  def trash_confirmation
  end

  def trash
    begin
      @tab.trash!
      BehaviorTransaction.trash_tab(club_and_operator_and_remarks.merge(tab: @tab))
      redirect_to dashboard_path, notice: '操作成功'
    rescue AASM::InvalidTransition
      redirect_to @tab, alert: '操作失败，无效的消费单状态'
    end
  end

  def cancel_confirmation
  end

  def cancel
    begin
      refund_amount = params[:refund_amount].to_f
      raise AmountCanNotBeNegetive.new if refund_amount < 0
      raise RefundAmountCanNotBeGreaterThanActualPrice.new if refund_amount > @tab.total_amount_in_reception
      @tab.cancel_and_refund(refund_amount)
      BehaviorTransaction.cancel_tab(club_and_operator_and_remarks.merge(tab: @tab))
      redirect_to @tab, notice: '操作成功'
    rescue InvalidState
      redirect_to cancel_confirmation_tab_path(@tab), alert: '操作失败，无效的消费单状态'
    rescue AmountCanNotBeNegetive
      redirect_to cancel_confirmation_tab_path(@tab), alert: '操作失败，退款金额不能小于0'
    rescue RefundAmountCanNotBeGreaterThanActualPrice
      redirect_to cancel_confirmation_tab_path(@tab), alert: '操作失败，退款金额不能大于实际付款'
    end
  end

  protected
    def find_tab
      @tab = @current_club.tabs.find(params[:id])
    end
end