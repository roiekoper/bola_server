class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def current_user
    return unless session[:user_id]
    @current_user ||= User.find(session[:user_id])
  end

  # general client json response with dynamic success variable
  # @param [Hash] opts
  def general_response(opts = {})
    success = opts[:success] || opts[:success] == nil
    success = false if opts[:errs].present? || opts[:err].present?
    render :json => { :success => success }.merge(opts)
  end

end
