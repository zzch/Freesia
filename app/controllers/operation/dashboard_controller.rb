# -*- encoding : utf-8 -*-
class Operation::DashboardController < Operation::BaseController
  
  def index
    @members_count = @current_club.members.available.unexpired.count
    @recently_members_count = @current_club.members.available.unexpired.rencently.count
    @daily_profit_in_total = OperationTransaction.daily_profit_in_total(@current_club)
    @daily_tabs_count = @current_club.tabs.finished.daily.count
  end
end
