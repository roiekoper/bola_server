class UsersController < ApplicationController

  def is_verified
    user = User.find_by_uuid(params.permit(:uuid)[:uuid])
    general_response :success => user.present?,
                     :user_id => user.try(:id),
                     :verified => user.try(:verified)
  end

  # create temp user until verified by verify_code, send verify_code to user phone number
  def get_code
    changed_params = {:uuid => nil,:phone_prefix => nil,:phone_number => nil}.merge(params.permit(:uuid, :phone_prefix, :phone_number))
    user = User.find_or_create_by(changed_params)
    general_response :success => user.errors.empty?,
                     :errs => user.errors.full_messages.join(', '),
                     :user_id => user.id
  end

  # check same user verify_code
  def verify_code
    user = User.find_by_id(params[:user_id])
    response = if user && user.verify_code == params[:verify_code].to_i
                 user.update_attribute :verified, true
                 session[:user_id] = user.id

                 { :msg => t('user.verified_success') }
               else
                 { :success => false, :msg => t('user.verified_failure') }
               end
    general_response response
  end
end
