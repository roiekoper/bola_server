module Ionic
  class PushService
    ENV = {
        'IONIC_APP_SECRET_KEY' => '2e9620e1664932407499dbab350456f3a5e7620440bffb09',
        'IONIC_APP_ID' => '794d9a04'
    }
    include HTTParty
    base_uri 'https://push.ionic.io'

    def initialize(device_token)
      @auth = {username: ENV['IONIC_APP_SECRET_KEY']}
      @headers = {
          'Content-Type' => 'application/json',
          'X-Ionic-Application-Id' => ENV['IONIC_APP_ID']
      }
      @device_token = device_token
    end

    def one_time_notification(notification)
      body = {:user_ids => [@device_token], :notification => notification}.to_json
      options = {:body => body, :basic_auth => @auth, :headers => @headers}
      self.class.post('/api/v1/push', options)
    end
  end
end