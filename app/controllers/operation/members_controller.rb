# -*- encoding : utf-8 -*-
class Operation::MembersController < Operation::BaseController
  before_action :find_member, only: %w(show edit update destroy cancel_confirmation cancel)
  
  def index
    @members = @current_club.members.available.order(issued_at: :desc).page(params[:page])
  end
  
  def show
  end

  def new
    if @user = User.where(id: params[:user_id]).first
      @member = Member.new
      render 'new_by_user'
    else
      @form = Operation::CreateMember.new
    end
  end
  
  def edit
  end

  def create
    if @user = User.where(id: params[:user_id]).first
      @member = Member.new(member_params)
      if @member.valid?
        begin
          @member = Member.create_by_user(club: @current_club, attributes: @member, user: @user)
          redirect_to @member, notice: '操作成功'
        rescue InvalidCard
          @form.errors.add(:base, '无效的会员卡')
          render action: 'new_by_user'
        end
      else
        render action: 'new_by_user'
      end
    else
      @form = Operation::CreateMember.new(params[:operation_create_member])
      if @form.valid?
        begin
          @member = Member.create_with_user(club: @current_club, attributes: @form)
          redirect_to @member, notice: '操作成功'
        rescue InvalidCard
          @form.errors.add(:base, '无效的会员卡')
          render action: 'new'
        end
      else
        render action: 'new'
      end
    end
  end
  
  def update
    if @member.update(member_params)
      redirect_to @member, notice: '操作成功'
    else
      render action: 'edit'
    end
  end

  def destroy
    begin
      @member.destroy
      redirect_to members_path, notice: '操作成功'
    rescue TransactionRecordExists
      redirect_to @member, alert: '操作失败！已存在消费！'
    end
  end

  def edit_amount
  end

  def update_amount
    @member.recharging(amount: params[:amount], operator: Operationerator.find(session['operator']['id']))
    redirect_to @member, notice: '操作成功'
  end

  def cancel_confirmation
  end

  def cancel
    begin
      @member.cancel!
      BehaviorTransaction.cancel_member(club_and_operator_and_remarks.merge(member: @member))
      redirect_to members_path, notice: '操作成功'
    rescue InvalidState
      redirect_to @member, alert: '操作失败，无效的会籍状态'
    end
  end

  protected
    def member_params
      params.require(:member).permit!
    end

    def find_member
      @member = @current_club.members.find(params[:id])
    end
end
