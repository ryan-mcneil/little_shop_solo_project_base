class AddressesController < ApplicationController

  def index
    @address = Address.find(params[:id])
  end

  def edit
    @address = Address.find(params[:id])
  end

  def update
    render file: 'errors/not_found', status: 404 if current_user.nil?
    @address = Address.find(params[:id])
    @user = @address.user
    @address.update(address_params)
    if @address.save && current_admin?
      flash[:success] = "Address Updated"
      redirect_to user_path(@address.user)
    elsif @address.save
      flash[:success] = "Address Updated"
      redirect_to profile_path
    else
      render :'addresses/edit'
    end

  end

  private

  def address_params
    params.require(:address).permit(:nickname, :street, :city, :state, :zip)
  end
end
