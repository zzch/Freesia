# -*- encoding : utf-8 -*-
class Operation::BayPricesController < Operation::BaseController
  before_action :find_card, only: %w(bulk_new bulk_create)

  def bulk_new
    @form = Operation::BulkCreateBayPrices.new
  end

  def bulk_create
    params[:operation_bulk_create_bay_prices][:bay_ids].reject!{|bay_id| bay_id.to_i.zero?}
    @form = Operation::BulkCreateBayPrices.new(params[:operation_bulk_create_bay_prices])
    if @form.valid?
      begin
        if @form.mode == 'set_price' or @form.mode == 'set_discount'
          BayPrice.bulk_create(club: @current_club, card: @card, form: @form)
        elsif @form.mode == 'destroy'
          BayPrice.bulk_destroy(club: @current_club, card: @card, form: @form)
        end
        redirect_to @card, notice: '操作成功！'
      rescue OriginalPriceNotFound
        redirect_to bulk_new_card_bay_prices_path(@card), alert: '操作失败，门市价不存在'
      rescue InvalidDiscount
        redirect_to bulk_new_card_bay_prices_path(@card), alert: '操作失败，折扣率不正确'
      end
    else
      render action: 'bulk_new'
    end
  end
  
  def destroy
    @bay_price = BayPrice.find(params[:id])
    @bay_price.destroy
    redirect_to @bay_price.playing_item.tab, notice: '操作成功！'
  end

  protected
    def find_card
      @card = @current_club.cards.find(params[:card_id])
    end
end