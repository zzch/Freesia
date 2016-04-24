# -*- encoding : utf-8 -*-
class Operation::MembershipsController < Operation::BaseController
  before_action :find_member, only: %w(new create)

  def new
    @form = Operation::CreateMembership.new
  end

  def create
    @form = Operation::CreateMembership.new(params[:operation_create_membership])
    if @form.valid?
      begin
        Membership.create_with_user(@member, @form)
        redirect_to @member, notice: '操作成功'
      rescue DuplicatedMembership
        redirect_to @member, alert: "操作失败，手机号为#{@form.phone}的用户已属于该会籍"
      end
    else
      render action: 'new'
    end
  end

  protected
    def find_member
      @member = @current_club.members.find(params[:member_id])
    end
end
