class UcbUpdateMailer < ApplicationMailer
  default from: 'brett.shollenberger@gmail.com'

  def ucb_class_match(ids)
    return if ids.empty?
    @matches = UserUcbClassMatch.where(id: ids).includes(:user, :ucb_class)
    @available = @matches.select { |m| m.ucb_class.available }
    @unavailable = @matches.select { |m| !m.ucb_class.available }
    user = @matches.first.user
    mail(to: user.email, subject: "UCB Class Match!")
  end

  def red_alert(match)
    @match = match

    mail(to: @match.user.email, subject: "RED ALERT: UCB Class Hold")
  end
end
