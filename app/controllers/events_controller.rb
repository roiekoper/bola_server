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
                          :location, :avatar, :invites)

    event = Event.create(attrs.slice(:title, :description, :location, :avatar).
                             merge(:start_date => DateTime.strptime("#{(Time.parse(params[:start_date]) + 1.days).strftime('%Y-%m-%d')} #{"#{Time.parse(params[:start_time]) + 2.hours}".to_time.strftime('%H:%M:%S')}",
                                                                    '%Y-%m-%d %H:%M:%S'),
                                   :end_date => params[:end_date].present? && params[:end_time].present? ? DateTime.strptime("#{(Time.parse(params[:end_date].to_s) + 1.days).strftime('%Y-%m-%d')} #{"#{Time.parse(params[:end_time].to_s) + 2.hours}".to_time.strftime('%H:%M:%S')}",
                                                                                                                             '%Y-%m-%d %H:%M:%S') : nil))

    if event.errors.empty?
      ([current_user.id] + attrs[:invites]).each do |user_id|
        EventsUser.create(:user_id => user_id,
                          :event_id => event.id,
                          :admin => current_user.id == user_id)
      end
    end

    general_response :success => event.errors.empty?,
                     :errs => event.errors.full_messages.join(', '),
                     :event => event.to_serialize(current_user)
  end

  def update_status
    events_user = EventsUser.where(:event_id => params[:id], :user_id => current_user.id).first
    response = if events_user
                 if events_user.update_status(params.permit(:status)[:status])
                   {:msg => t('event.update_success')}
                 else
                   {:errs => events_user.errors.full_messages}
                 end
               else
                 {:errs => t('event.no_event')}
               end
    general_response response
  end
end
