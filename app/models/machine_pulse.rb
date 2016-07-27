class MachinePulse < ActiveRecord::Base
  belongs_to :machine

  def self.response params = []
    if !params[:f].blank? and !params[:t].blank? and !params[:m].blank? and !params[:g].blank? and !params[:p].blank?
      inner_params = Hash[Base64.decode64(params[:p]).gsub(/[{}"]/, '').split(',').map{|param_pair| param_pair.split(':')}].symbolize_keys
      out_of_stock = inner_params[:OOS] == 'Y' ? true : false
      battery = inner_params[:BTY].to_i
      create!(machine: machine, frame_number: params[:f], frame_type: params[:t], gprs_intensity: params[:g], out_of_stock: out_of_stock, battery: battery) if machine = Machine.where(serial_number: params[:m]).first
    else
      
    end
  end
end