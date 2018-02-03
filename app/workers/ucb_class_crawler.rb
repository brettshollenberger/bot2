require "capybara/rails"

class UcbClassCrawler
  include Sidekiq::Worker

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

  def canonical_date(day)
    ({
      mon: :monday,
      tues: :tuesday,
      wed: :wednesday,
      thurs: :thursday,
      fri: :friday,
      sat: :saturday,
      sun: :sunday
    }.with_indifferent_access[day] || day).to_sym.downcase
  end

  def perform
    response = HTTParty.get("https://newyork.ucbtrainingcenter.com/course/open"); 1
    html     = Nokogiri::HTML(response); 1

    active_preferences = UserUcbPreference.active; 1
    courses            = active_preferences.group_by(&:class_name)

    courses.each do |course, preferences|
      keys    = html.css(".panel:contains('#{course}') thead th").map { |th| th.text }.uniq
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
            full_day_names = raw_days.all? { |d| DAYS.include?(d.downcase) }

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

          days.map! { |d| canonical_date(d) }

          start_time = time.split("-").first
          start_time = (start_time =~ /am|pm/) ? start_time : "#{start_time}pm"
          end_time = time.split("-").last
          start_hour, start_minute = UcbClass.time_string_to_hour_minute(start_time)
          end_hour, end_minute = UcbClass.time_string_to_hour_minute(end_time)
          o[:days] = days
          o[:days_per_week] = days.count
          o[:start_hour]   = start_hour
          o[:start_minute] = start_minute
          o[:end_hour]     = end_hour
          o[:end_minute]   = end_minute
          o[:starts_at]    = EST.parse(start_time)
          o[:ends_at]      = EST.parse(time.split("-").last)
        end
      end

      historian_user = User.find_by_email("brett.shollenberger@gmail.com")
      dates_to_save = []
      courses = options.map do |o|
        course = UcbClass.find_or_initialize_by(
          ucb_id: o["ucb_id"]
        )

        course.level            = o["Level"]
        course.teacher          = o["Teacher"]
        course.available        = o["Actions"] != "Sold Out"
        course.registration_url = o["url"]
        course.human_dates      = o["Day / Time"]
        course.history_user_id  = historian_user.id
        course.start_hour       = o[:start_hour]
        course.start_minute     = o[:start_minute]
        course.end_hour         = o[:end_hour]
        course.end_minute       = o[:end_minute]

        unless course.persisted?
          course_type = COURSE_TYPES.detect { |c| c[:days] == o[:days].count }
          weeks = course_type[:weeks]
          current_week = EST.parse(o["Start Date"]).beginning_of_week
          dates = []

          weeks.times do |week_number|
            o[:days].each do |day_of_week|
              dates.push(current_week.next_week(day_of_week.downcase.to_sym) - 1.week)
            end
            current_week = current_week.next_week.beginning_of_week
          end

          dates.each do |date|
            d = UcbClassDate.new(
              ucb_class: course,
              starts_at: date,
              start_hour: o[:start_hour],
              start_minute: o[:start_minute],
              end_hour: o[:end_hour],
              end_minute: o[:end_minute]
            )
            dates_to_save.push(d)
          end
        end

        course
      end

      changed = courses.select(&:should_record_history?)
      courses.each(&:save!)
      dates_to_save.each(&:save!)

      preferences.select.each do |preference|
        p = preference["preferences"]
        available_after = p["available_after"]
        available_before = p["available_before"]

        desired = changed.select do |c|
          c.dates.all? { |d| %w(Saturday Sunday).include?(d.starts_at.strftime("%A")) } ||
            (available_after.nil? || c.starts_after?(EST.parse(available_after))) && (available_before.nil? || c.ends_before?(EST.parse(available_before)))
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
