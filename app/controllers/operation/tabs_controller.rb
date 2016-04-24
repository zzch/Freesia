# -*- encoding : utf-8 -*-
class Operation::TabsController < Operation::BaseController
  before_action :find_tab, only: %w(show)
  
  def index
    @tabs = Tab.page(params[:page])
  end
  
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
  
  def new
    @tab = Tab.new
    @form = Operation::VisitorSetUpTab.new
  end
  
  def member_set_up
    begin
      raise InvalidUser.new if tab_params[:user_id].blank?
      @tab = Tab.set_up(tab_params.merge({ club_id: @current_club.id, operator_id: session['operator']['id'] }), params[:vacancy_ids])
      redirect_to @tab, notice: '操作成功！'
    rescue AlreadyInUse
      render action: 'new'
    rescue InvalidUser
      redirect_to new_tab_path(vacancy_id: params[:vacancy_id]), alert: '操作失败！无效的用户！'
    end
  end

  def visitor_set_up
    @form = Operation::VisitorSetUpTab.new(params[:operation_visitor_set_up_tab])
    if @form.valid?
      @tab = Tab.set_up(club: @current_club, form: @form)
      redirect_to @tab, notice: '操作成功'
    else
      render action: 'new'
    end
  end

  def checkout
    @playing_items = @tab.playing_items.includes(:balls).includes(:vacancy)
    @provision_items = @tab.provision_items
    @extra_items = @tab.extra_items
    @members = @tab.user.members.by_club(@current_club).includes(:card)
    @stored_card_members = @members.select{|member| member.card.type_stored?}
  end

  def print
    render layout: false
  end

  def checking
    begin
      method = params[:method].to_sym
      @tab.checking(method)
      case method
      when :app then redirect_to(@tab, notice: '操作成功！')
      when :reception
        if @current_club.preference(:print_receipt)
          redirect_to(print_tab_path(@tab), notice: '操作成功！')
        else
          redirect_to(@tab, notice: '操作成功！')
        end
      end
    rescue UndeterminedItem
      redirect_to checkout_tab_path(@tab), alert: '操作失败！存在未确定的消费条目！'
    rescue InvalidState
      redirect_to checkout_tab_path(@tab), alert: '操作失败！消费单状态不正确！'
    rescue InvalidConfirmMethod
      redirect_to checkout_tab_path(@tab), alert: '操作失败！无效的确认方式！'
    rescue InvalidCardType
      redirect_to checkout_tab_path(@tab), alert: '操作失败！卡类型不正确！'
    rescue InvalidCharingType
      redirect_to checkout_tab_path(@tab), alert: '操作失败！付款类型无效！'
    rescue InsufficientBall
      redirect_to checkout_tab_path(@tab), alert: '操作失败！计球卡余额不足！'
    rescue InsufficientMinute
      redirect_to checkout_tab_path(@tab), alert: '操作失败！计时卡余额不足！'
    rescue InsufficientDeposit
      redirect_to checkout_tab_path(@tab), alert: '操作失败！储值卡余额不足！'
    end
  end

  def confirm
    begin
      @tab.confirm
      redirect_to @tab, notice: '操作成功！'
    rescue InvalidState
      redirect_to @tab, alert: '操作失败！无效的订单状态！'
    end
  end
  
  def cancel
    begin
      @tab.cancel!
      redirect_to @tab, notice: '操作成功！'
    rescue AlreadyInUse
      redirect_to @tab, alert: '操作失败！'
    end
  end

  def drop
    begin
      @tab.drop(session['operator']['id'])
      redirect_to @tab, notice: '操作成功！'
    rescue AlreadyInUse
      redirect_to @tab, alert: '操作失败！'
    end
  end

  def progressing
    @tabs = @current_club.tabs.progressing.order(entrance_time: :desc).page(params[:page])
  end

  def confirming
    @tabs = @current_club.tabs.confirming.order(entrance_time: :desc).page(params[:page])
  end

  def finished
    @tabs = @current_club.tabs.finished.order(departure_time: :desc).page(params[:page])
  end

  def cancelled
    @tabs = @current_club.tabs.cancelled.order(entrance_time: :desc).page(params[:page])
  end

  def search
    @tabs = @current_club.tabs.search(params).page(params[:page])
  end

  protected
    def tab_params
      params.require(:tab).permit!
    end

    def find_tab
      @tab = @current_club.tabs.find(params[:id])
    end
end