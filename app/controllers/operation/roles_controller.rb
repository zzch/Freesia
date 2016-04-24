# -*- encoding : utf-8 -*-
class Operation::RolesController < Operation::BaseController
  before_action :find_role, only: %w(show edit update destroy)
  
  def index
    @roles = @current_club.roles.order(created_at: :desc).page(params[:page])
  end
  
  def show
  end

  def new
    @role = Role.new
  end
  
  def edit
  end

  def create
    @role = @current_club.roles.new(role_params)
    if @role.save
      redirect_to @role, notice: '操作成功'
    else
      render action: 'new'
    end
  end
  
  def update
    if @role.update(role_params)
      redirect_to @role, notice: '操作成功'
    else
      render action: 'edit'
    end
  end

  protected
    def role_params
      params.require(:role).permit!
    end

    def find_role
      @role = @current_club.roles.find(params[:id])
    end
end
