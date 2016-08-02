# -*- encoding : utf-8 -*-
class Administration::BaysController < Administration::BaseController
  before_action :find_club
  
  def bulk_new_pairing
  end
  
  def bulk_create_pairing
    begin
      Bay.bulk_create_pairing(club: @club, bay_ids: params[:bay_ids])
      redirect_to [:admin, @club], notice: '操作成功'
    rescue ActiveRecord::RecordNotFound
      redirect_to bulk_new_pairing_admin_club_bays_path(@club), alert: '操作失败，找不到数据'
    rescue InvalidState
      redirect_to bulk_new_pairing_admin_club_bays_path(@club), alert: '操作失败，无效的状态'
    end
  end

  protected
    def bay_params
      params.require(:bay).permit!
    end

    def find_club
      @club = Club.find(params[:club_id])
    end

    def find_bay
      @bay = Bay.find(params[:id])
    end
end