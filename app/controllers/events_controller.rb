class EventsController < ApplicationController
  def index
    response = (current_user ? current_user.json_events : { :msg => t('app.user_disconnected') }).
        merge(:success => current_user.present?)
    general_response response
  end

  def create
    attrs = params.permit(:title, :description,
                          :start_date, :end_date,
                          :end_time, :start_time,
                          :location)

    p '============================='
    p '============================='
    p '============================='
    p DateTime.strptime("#{(Time.parse(params[:start_date]) + 1.days).strftime('%Y-%m-%d')} #{"#{Time.parse(params[:start_time]) + 2.hours}".to_time.strftime('%H:%M:%S')}",
                        '%Y-%m-%d %H:%M:%S')
    p '+++++++++++++++'
    p DateTime.strptime("#{(Time.parse(params[:end_date]) + 1.days).strftime('%Y-%m-%d')} #{"#{Time.parse(params[:end_time]) + 2.hours}".to_time.strftime('%H:%M:%S')}",
                        '%Y-%m-%d %H:%M:%S')

    p '============================='
    p '============================='
    p '============================='

    p attrs.slice(:title, :description, :location).
          merge(:start_date => DateTime.strptime("#{(Time.parse(params[:start_date]) + 1.days).strftime('%Y-%m-%d')} #{"#{Time.parse(params[:start_time]) + 2.hours}".to_time.strftime('%H:%M:%S')}",
                                                 '%Y-%m-%d %H:%M:%S'),
                :end_date => DateTime.strptime("#{(Time.parse(params[:end_date]) + 1.days).strftime('%Y-%m-%d')} #{"#{Time.parse(params[:end_time]) + 2.hours}".to_time.strftime('%H:%M:%S')}",
                                               '%Y-%m-%d %H:%M:%S'))

    p '============================='
    p '============================='
    p '============================='


    event = Event.create(params.permit(:title, :description,
                                       :start_date, :end_date,
                                       :end_time, :start_time,
                                       :location))

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
