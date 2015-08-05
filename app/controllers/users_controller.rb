class UsersController < ApplicationController

  def get_code
    user = User.find_or_create_by params.permit(:uuid, :phone_prefix, :phone_number)
    render :json => {:success => true, :user_id => user.id}
  end

  def verified_user
    user = User.find_by_id(params[:user_id])
    render :json => if user && user.verify_code == params[:verify_code].to_i
                      user.update_attribute :verified, true
                      {:msg => 'user is verified'}
                    else
                      {:msg => 'wrong code'}
                    end
  end
end
