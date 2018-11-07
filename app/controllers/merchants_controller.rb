class MerchantsController < ApplicationController
  def index
    if current_admin?
      @merchants = User.where(role: :merchant).order(:name)
    else
      @merchants = User.where(role: :merchant, active: true).order(:name)
    end
  end

  def show
    render file: 'errors/not_found', status: 404 unless current_user
    @merchant = User.find_by(slug: params[:slug])
    if current_admin?
      @orders = current_user.merchant_orders
      if @merchant.user?
        redirect_to user_path(@merchant)
      end
    elsif current_user != @merchant
      render file: 'errors/not_found', status: 404
    end
  end
end
