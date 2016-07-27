# -*- encoding : utf-8 -*-
class Administration::BaysController < Administration::BaseController
  before_action :find_club
  
  def bulk_new_pairing
  end
  
  def bulk_create_pairing
    begin
      params[:bay_ids].each do |bay_id, machine_id|
        @club.bays.find(bay_id)
        Machine.find(machine_id)
      end
    rescue ActiveRecord::RecordNotFound
      
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