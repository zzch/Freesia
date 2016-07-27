# -*- encoding : utf-8 -*-
class Administration::ClubsController < Administration::BaseController
  before_action :find_club, only: %w(show edit update destroy)
  
  def index
    @clubs = Club.page(params[:page])
  end
  
  def show
  end
  
  def new
    @club = Club.new
  end
  
  def edit
  end
  
  def create
    @club = Club.new(club_params)
    if @club.save
      redirect_to [:admin, @club], notice: '操作成功'
    else
      render action: 'new'
    end
  end
  
  def update
    if @club.update(club_params)
      redirect_to [:admin, @club], notice: '操作成功'
    else
      render action: 'edit'
    end
  end

  protected
    def club_params
      params.require(:club).permit!
    end

    def find_club
      @club = Club.find(params[:id])
    end
end