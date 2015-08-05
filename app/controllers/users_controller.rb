class UsersController < ApplicationController

  # create temp user until verified by verify_code, send verify_code to user phone number
  def get_code
    user = User.find_or_create_by params.permit(:uuid, :phone_prefix, :phone_number)
    general_response :user_id => user.id
  end

  # check same user verify_code
  def verified_user
    user = User.find_by_id(params[:user_id])
    response = if user && user.verify_code == params[:verify_code].to_i
                 user.update_attribute :verified, true
                 { :msg => t('user.verified_success') }
               else
                 { :success => false, :msg => t('user.verified_failure') }
               end
    general_response response
  end
end
