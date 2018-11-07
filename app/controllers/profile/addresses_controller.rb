class Profile::AddressesController < ApplicationController

  def new
    # render file: 'errors/not_found', status: 404 unless current_user
    @user = current_user
    if current_admin? && params[:user_id]
      @user = User.find_by(slug: params[:user_id])
    end
    @address = Address.new
  end

  def create
    @user = User.find_by(slug: params[:user_id])
    @address = @user.addresses.create(address_params)
    if @user.addresses.size == 1
      @address.default_add = true
    end
    if @address.save && @user == current_user
      flash[:success] = "Address created"
      redirect_to profile_path
    elsif @address.save
      flash[:success] = "Address created"
      redirect_to user_path(@user)
    else
      render :'profile/addresses/new'
    end
  end

  private

  def address_params
    params.require(:address).permit(:nickname, :street, :city, :state, :zip)
  end
end
