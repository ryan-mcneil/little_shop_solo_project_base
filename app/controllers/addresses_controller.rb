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
    if params[:toggle]
      @address.active = false if params[:toggle] == "disable"
      @address.active = true if params[:toggle] == "enable"
      # if @address == @user.default_address && params[:toggle] == "disable" && @user.other_addresses.count > 1
      @address.save
      flash[:success] = "'#{@address.nickname}' address is now #{params[:toggle]}d"
      redirect_to current_admin? ? user_path(@address.user) : profile_path
    else
      @address.update(address_params)
      if @address.save
        flash[:success] = "Address Updated"
        redirect_to current_admin? ? user_path(@address.user) : profile_path
      else
        render :'addresses/edit'
      end
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
