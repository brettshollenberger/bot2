require "capybara/rails"
require 'twilio-ruby'

class UcbClassHolder
  include Sidekiq::Worker
  sidekiq_options queue: 'critical'

  def perform(class_match_id)
    match = UserUcbClassMatch.find(class_match_id)
    phone_alert(match)
    email_alert(match)

    hold_url = place_hold(match)

    if !!(hold_url =~ /course\/register\/\d+/)
      hold =  UcbClassHold.create(
        user_id: match.user_id,
        ucb_class_id: match.ucb_class_id,
        hold_url: hold_url
      )
    end
  end

  def email_alert(match)
    UcbUpdateMailer.red_alert(match).deliver_now
  end

  def phone_alert(match)
    account_sid     = ENV["TWILIO_SID"]
    auth_token      = ENV["TWILIO_TOKEN"]
    outgoing_number = ENV["TWILIO_NUMBER"]
    twilio_url      = ENV["TWILIO_URL"]

    @client = Twilio::REST::Client.new account_sid, auth_token
    @client.api.account.calls.create(
      from: "+#{outgoing_number}",
      to: match.user.phone,
      url: twilio_url
    )
  end

  def place_hold(match)
    session = Rails.instance_variable_get(:@capybara_session)

    url = match.ucb_class.registration_url
    page = "https://newyork.ucbtrainingcenter.com/login?http_referer=#{url}"
    session.visit(page)
    session.find(:css, "form input[name='email']").set(match.user.email)
    session.find(:css, "form input[name='password']").set(match.user.ucb_password)
    session.find(:css, "input[value='Login'][type='submit']").click
    session.find(:css, "a.register_btn").click
    url = session.current_url
    session.reset!
    return url
  end
end
