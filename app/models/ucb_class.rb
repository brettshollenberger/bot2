class UcbClass < ActiveRecord::Base
  include Historiographer
  validates_presence_of :level, :start_hour, :start_minute, :end_hour, :end_minute, :teacher
  has_many :user_ucb_class_matches
  has_many :ucb_class_holds
  has_many :dates, class_name: "UcbClassDate"

  scope :available, -> { where(available: true) }

  scope :starts_after, -> (time_str) { where("start_hour >= ? AND start_minute >= ?", *time_string_to_hour_minute(time_str))}

  scope :ends_before, -> (time_str) { where("end_hour <= ? AND end_minute <= ?", *time_string_to_hour_minute(time_str))}

  scope :between, -> (start_str, end_str) { starts_after(start_str).ends_before(end_str) }

  def self.time_string_to_hour_minute(time_string)
    hour   = EST.parse(time_string).hour
    minute = EST.parse(time_string).min

    [hour, minute]
  end

  def url
    "https://newyork.ucbtrainingcenter.com#{registration_url}"
  end

  def starts_after?(timestamp)
    start_hour >= timestamp.hour && start_minute >= timestamp.min
  end

  def ends_before?(timestamp)
    end_hour <= timestamp.hour && end_minute <= timestmap.min
  end

  def classes
    dates.sort_by(&:starts_at).pluck(:starts_at).map(&:to_date)
  end
end
