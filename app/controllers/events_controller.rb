class EventsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
    response = (current_user ? current_user.json_events : {:msg => t('app.user_disconnected')}).
        merge(:success => current_user.present?)
    general_response response
  end

  def create
    attrs = params.permit(:title, :description,
                          :start_date, :end_date,
                          :end_time, :start_time,
                          :location, :avatar)

    event = Event.create(attrs.slice(:title, :description, :location, :avatar).
                             merge(:start_date => DateTime.strptime("#{(Time.parse(params[:start_date]) + 1.days).strftime('%Y-%m-%d')} #{"#{Time.parse(params[:start_time]) + 2.hours}".to_time.strftime('%H:%M:%S')}",
                                                                    '%Y-%m-%d %H:%M:%S'),
                                   :end_date => params[:end_date].present? && params[:end_time].present? ? DateTime.strptime("#{(Time.parse(params[:end_date].to_s) + 1.days).strftime('%Y-%m-%d')} #{"#{Time.parse(params[:end_time].to_s) + 2.hours}".to_time.strftime('%H:%M:%S')}",
                                                                                                                             '%Y-%m-%d %H:%M:%S') : nil))

    if event.errors.empty?
      EventsUser.create(:user_id => current_user.id,
                        :event_id => event.id,
                        :admin => true)
    end

    general_response :success => event.errors.empty?,
                     :errs => event.errors.full_messages.join(', '),
                     :event_id => event.id
  end
end
