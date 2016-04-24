# -*- encoding : utf-8 -*-
class Operation::BaysController < Operation::BaseController
  before_action :find_bay, only: %w(show edit update open close)
  
  def index
    @bays = @current_club.bays.includes(:tags)
  end
  
  def show
  end
  
  def new
    @bay = Bay.new
  end
  
  def edit
  end
  
  def create
    @bay = @current_club.bays.new(bay_params)
    if @bay.save
      @bay.set_tags
      redirect_to @bay, notice: "<h4>操作成功</h4><p>接下来您可能希望：#{view_context.link_to('创建打位', new_bay_path)} 或 #{view_context.link_to('批量创建打位', bulk_new_bays_path)}"
    else
      render action: 'new'
    end
  end
  
  def update
    if @bay.update(bay_params)
      @bay.set_tags
      redirect_to @bay, notice: '操作成功'
    else
      render action: 'edit'
    end
  end

  def bulk_new
    @form = Operation::BulkCreateBays.new
  end

  def bulk_create
    @form = Operation::BulkCreateBays.new(params[:operation_bulk_create_bays])
    if @form.valid?
      begin
        Bay.bulk_create(club: @current_club, form: @form)
        redirect_to bays_path, notice: "<h4>操作成功</h4><p>接下来您可能希望：#{view_context.link_to('批量创建打位', bulk_new_bays_path)} 或 #{view_context.link_to('创建打位', new_bay_path)}"
      rescue DuplicatedBay
        @form.errors.add(:base, '打位名称重复')
        render action: 'bulk_new'
      end
    else
      render action: 'bulk_new'
    end
  end

  def open
    begin
      @bay.open!
      redirect_to @bay, notice: '操作成功'
    rescue AASM::InvalidTransition
      redirect_to @bay, alert: '操作失败，无效的打位状态'
    end
  end

  def close
    begin
      @bay.close!
      redirect_to @bay, notice: '操作成功'
    rescue AASM::InvalidTransition
      redirect_to @bay, alert: '操作失败，无效的打位状态'
    end
  end

  protected
    def bay_params
      params.require(:bay).permit!
    end

    def find_bay
      @bay = @current_club.bays.find(params[:id])
    end
end