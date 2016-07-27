# -*- encoding : utf-8 -*-
class Administration::MachinesController < Administration::BaseController
  before_action :find_machine, only: %w(show edit update destroy)
  
  def index
    @machines = Machine.page(params[:page])
  end
  
  def show
  end
  
  def new
    @machine = Machine.new
  end
  
  def edit
  end
  
  def create
    @machine = Machine.new(machine_params)
    if @machine.save
      redirect_to [:admin, @machine], notice: '操作成功'
    else
      render action: 'new'
    end
  end
  
  def update
    if @machine.update(machine_params)
      redirect_to [:admin, @machine], notice: '操作成功'
    else
      render action: 'edit'
    end
  end

  protected
    def machine_params
      params.require(:machine).permit!
    end

    def find_machine
      @machine = Machine.find(params[:id])
    end
end