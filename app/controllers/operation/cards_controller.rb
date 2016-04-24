# -*- encoding : utf-8 -*-
class Operation::CardsController < Operation::BaseController
  before_action :find_card, only: %w(show edit update destroy)
  
  def index
    @cards = @current_club.cards.order(created_at: :desc).page(params[:page])
  end
  
  def show
  end

  def new
    @card = Card.new
  end
  
  def edit
  end

  def create
    @card = @current_club.cards.new(card_params)
    if @card.save
      @card.set_bay_tags
      redirect_to @card, notice: '操作成功'
    else
      render action: 'new'
    end
  end
  
  def update
    if @card.update(card_params)
      @card.set_bay_tags
      redirect_to @card, notice: '操作成功'
    else
      render action: 'edit'
    end
  end

  def destroy
    begin
      @card.destroy
      redirect_to cards_path, notice: '操作成功'
    rescue MemberExists
      redirect_to @card, alert: '操作失败，会员卡已存在会籍'
    end
  end

  def async_show
    begin
      card = @current_club.cards.find(params[:id])
      render json: JsonMessenger.new(card)
    rescue ActiveRecord::RecordNotFound
      render json: JsonMessenger.new('找不到会员卡', false)
    end
  end

  protected
    def card_params
      params.require(:card).permit!
    end

    def find_card
      @card = @current_club.cards.find(params[:id])
    end
end
