# -*- encoding : utf-8 -*-
class Operation::TabsController < Operation::BaseController
  before_action :find_tab, only: %w(show checkout check)
  
  def show
    if @tab.progressing?
      render 'progressing_show'
    else
      @playing_items = @tab.playing_items.includes(:balls).includes(:vacancy)
      @provision_items = @tab.provision_items
      @extra_items = @tab.extra_items
      @members = @tab.user.members.by_club(@current_club).includes(:card)
      @stored_card_members = @members.select{|member| member.card.type_stored?}
      render 'finished_show'
    end
  end

  def checkout
    @driving_form = Operation::UpdateDrivingLineItemPayMethod.new
    @non_driving_form = Operation::UpdateNonDrivingLineItemPayMethod.new
  end

  def check
    begin
      @tab.check
      redirect @tab, notice: '操作成功'
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
      render action: 'new'
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

  protected
    def find_tab
      @tab = @current_club.tabs.find(params[:id])
    end
end