# -*- encoding : utf-8 -*-
class Operation::ChangelogsController < Operation::BaseController
  
  def index
    @changelogs = Changelog.all
  end
end