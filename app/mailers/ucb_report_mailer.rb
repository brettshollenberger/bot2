class UcbReportMailer < ApplicationMailer
  default from: 'brett.shollenberger@gmail.com'

  def ucb_report(file)
    @file = file
    mail(to: "brett.shollenberger@gmail.com", subject: "UCB Report")
  end
end
