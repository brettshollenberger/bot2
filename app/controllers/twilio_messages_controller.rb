class TwilioMessagesController < ActionController::Base
  protect_from_forgery with: :exception

  def create
    render xml: Twilio::TwiML::VoiceResponse.new { |r| r.say "Hello world!" }.to_s
  end
end
