class MachineReport < ActiveRecord::Base
  belongs_to :machine

  def self.response params = []
    ActiveRecord::Base.transaction do
      if !params[:f].blank? and !params[:t].blank? and !params[:m].blank? and !params[:g].blank? and !params[:p].blank?
        inner_params = Hash[Base64.decode64(params[:p]).gsub(/[{}"]/, '').split(',').map{|param_pair| param_pair.split(':')}].symbolize_keys
        dispensation_id = inner_params[:TID]
        success = inner_params[:OB] == 'Y' ? true : false
        error_code = inner_params[:EC]
        if machine = Machine.where(serial_number: params[:m]).first and machine.reports.where(frame_number: params[:f]).blank? and machine_dispensation = machine.dispensations.where(id: dispensation_id).first
          create!(machine: machine, frame_number: params[:f], frame_type: params[:t], gprs_intensity: params[:g], machine_dispensation: machine_dispensation, success: success, error_code: error_code)
          machine.up!
          machine_dispensation.confirm! if success
          content = Base64.encode64('1').strip
          "#{params[:f]},#{content.length},#{content}"
        end
      end
    end
  end
end
