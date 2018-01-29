require "capybara/rails"

class UcbClassCrawler
  include Sidekiq::Worker

  Time.zone = "EST"
  EST = Time.zone

  COURSE_TYPES = [
    { days: 1, weeks: 8 },
    { days: 2, weeks: 4 },
    { days: 4, weeks: 1 },
    { days: 5, weeks: 1 }
  ]

  ABBREVS = %w(mon tues wed thurs fri sat sun)
  DAYS    = %w(monday tuesday wednesday thursday friday saturday sunday)

  def all_days
    @all_days ||= begin
                    days = DAYS.clone.concat(DAYS.clone.map { |d| d.pluralize }).concat(ABBREVS)
                    days.clone.concat(days.map { |d| d.capitalize })
                  end
  end

  def perform
    response = HTTParty.get("https://newyork.ucbtrainingcenter.com/course/open"); 1
    html     = Nokogiri::HTML(response); 1

    active_preferences = UserUcbPreference.active; 1
    courses            = active_preferences.group_by(&:class_name)

    courses.each do |course, preferences|
      keys    = html.css(".panel:contains('#{course}') thead th").map { |th| th.text }
      options = html.css(".panel:contains('#{course}') tbody tr").map do |tr|
        h = keys.zip(tr.css("td").map do |td|
          td.text.gsub(/\n/) {}.strip
        end).to_h
        h["url"] = tr.css("td a").first.attributes["href"].value
        h["ucb_id"] = h["url"].split("/").last.to_i
        h
      end

      options.map! do |o|
        o.tap do
          split = o["Day / Time"].split(/(\d)/)
          days = split[0]
          time = split[1..-1].join("")
          raw_days = days.scan(Regexp.new(all_days.join("|")))
          day_span = !!(days =~ /-/)

          if day_span
            full_day_names = raw_days.all? { |d| DAYS =~ Regexp.new(d.downcase) }

            fill_with = full_day_names ? DAYS : ABBREVS
            days = []
            current_day = raw_days.first
            start_index = fill_with.index { |d| d == current_day.downcase }

            until current_day.downcase == raw_days.last.downcase
              days.push(current_day.downcase)
              start_index += 1
              current_day = fill_with[start_index]
            end
            days.push(current_day)
          else
            days = raw_days
          end

          start_time = time.split("-").first
          start_time = (start_time =~ /am|pm/) ? start_time : "#{start_time}pm"
          o[:days] = days
          o[:days_per_week] = days.count
          o[:starts_at] = EST.parse(start_time)
          o[:ends_at] = EST.parse(time.split("-").last)
        end
      end

      historian_user = User.find_by_email("brett.shollenberger@gmail.com")
      courses = options.map do |o|
        course = UcbClass.find_or_initialize_by(
          ucb_id: o["ucb_id"]
        )

        course.level            = o["Level"]
        course.teacher          = o["Teacher"]
        course.available        = o["Actions"] != "Sold Out"
        course.registration_url = o["url"]
        course.human_dates = o["Day / Time"]
        course.history_user_id = historian_user.id

        unless course.persisted?
          course.starts_at = o[:starts_at].in_time_zone(EST)
          course.ends_at   = o[:ends_at].in_time_zone(EST)
        end

        course
      end

      changed = courses.select(&:should_record_history?)
      courses.each(&:save!)

      preferences.each do |preference|
        p = preference["preferences"]
        available_after = p["available_after"]
        available_before = p["available_before"]

        desired = changed.select do |c|
          (available_after.nil? || c.starts_at >= EST.parse(available_after)) && (available_before.nil? || c.ends_at <= EST.parse(available_before))
        end

        class_matches = desired.map do |d|
          UserUcbClassMatch.create(
            user_id: preference.user_id,
            ucb_class_id: d.id
          )
        end

        class_matches.select { |c| c.ucb_class.available }.each do |match|
          UcbClassHolder.new.perform(match.id)
        end
      end

    end
  end

end
