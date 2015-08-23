class UsersController < ApplicationController
  skip_before_action :verify_authenticity_token

  def is_verified
    user = User.find_by_uuid(params.permit(:uuid)[:uuid])

    if user.present?
      session[:user_id] = user.id
    end

    general_response :success => true,
                     :user => user.try(:to_serialize) || {:verified => false}
  end

  # create temp user until verified by verify_code, send verify_code to user phone number
  def get_code
    changed_params = {:uuid => nil, :phone_prefix => nil, :phone_number => nil}.merge(params.permit(:uuid, :phone_prefix, :phone_number))
    changed_params[:phone_prefix] = changed_params[:phone_prefix].to_i
    user = User.find_or_create_by(changed_params)
    general_response :success => user.errors.empty?,
                     :errs => user.errors.full_messages.join(', '),
                     :user => {:id => user.id}
  end

  # check same user verify_code
  def verify_code
    user = User.find_by_id(params[:id])
    response = if user && user.verify_code == params[:verify_code].to_i
                 user.update_attribute :verified, true
                 session[:user_id] = user.id

                 {:msg => t('user.verified_success'), :user => user.to_serialize}
               else
                 {:success => false, :errs => t('user.verified_failure')}
               end
    general_response response
  end

  def update
    user = User.find_by_id(params[:id])
    response = if user
                 if user.update_attributes(params.permit(:name, :avatar))
                   {:msg => t('user.update_success'), :user => user.to_serialize}
                 else
                   {:errs => user.errors.full_messages}
                 end
               else
                 {:errs => t('user.no_user')}
               end
    general_response response
  end

  def verified_phones
    contacts = params[:contacts].inject({}) do |h, phone_number|
      h.merge phone_number.to_s.gsub(/\D/, '')[-9..-1].try(:to_i) => phone_number
    end
    general_response(contacts: User.select(:id, :phone_number).
                         where('id != ?', current_user.id).
                         where(:phone_number => contacts.keys.compact).inject({}) do |h, user|
                       h.merge contacts[user.phone_number] => user.id
                     end)
  end

  def push_token
    Rails.logger.info params
  end
end
