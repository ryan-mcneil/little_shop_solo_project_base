class AddressesController < ApplicationController

  def index
    @address = Address.find(params[:id])
  end

  def edit
    @address = Address.find(params[:id])
  end

  def update
    binding.pry
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

  def toggle_address(enable_disable)
  if enable_disable == "Enable"
    @item.update(active: true)
    notice = "Item ##{params[:id]} now available for sale"
  elsif enable_disable == "Disable"
    @item.update(active: false)
    notice = "Item ##{params[:id]} no longer for sale"
  end
  return notice
end
end
