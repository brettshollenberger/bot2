class UcbClassReport
  include Sidekiq::Worker

  def perform
    course_histories = UcbClassHistory.where("history_started_at >= ?", 7.days.ago.beginning_of_day)
    days = course_histories.group_by_day(&:history_started_at)
    ordered_keys = days.keys.sort.reverse

    t = Tempfile.new("report")

    ordered_keys.each do |key|
      t.puts "#{key.strftime("%B %e, %Y")}"
      t.puts  
      histories = days[key]
      if histories.present?
        histories.sort_by(&:history_started_at).each do |h|
          t.puts "#{h.level} #{h.human_dates} was #{h.available ? "available" : "full"} at #{h.history_started_at.in_time_zone(PT).strftime("%B %e, %Y %I:%M%P %Z")}"
        end
        t.puts
      else
        t.puts "no changes."
      end
      t.puts "-----------"
      t.puts
    end

    UcbReportMailer.ucb_report(t).deliver_now
    t.close
    t.unlink

  end

end
