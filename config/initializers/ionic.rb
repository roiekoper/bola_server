module Ionic
  class PushService
    ENV = {
        'IONIC_APP_SECRET_KEY' => '2e9620e1664932407499dbab350456f3a5e7620440bffb09',
        'IONIC_APP_ID' => '794d9a04'
    }
    include HTTParty
    base_uri 'https://push.ionic.io'

    def initialize
      @auth = {username: ENV['IONIC_APP_SECRET_KEY']}
      @headers = {
          'Content-Type' => 'application/json',
          'X-Ionic-Application-Id' => ENV['IONIC_APP_ID']
      }
    end

    def notify(user_tokens, notification)
      body = {:user_ids => user_tokens, :notification => notification}.to_json
      options = {:body => body, :basic_auth => @auth, :headers => @headers}
      self.class.post('/api/v1/push', options)
    end
  end
end