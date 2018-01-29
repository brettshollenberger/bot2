class UcbClass < ActiveRecord::Base
  include Historiographer
  validates_presence_of :level, :starts_at, :ends_at, :teacher
  has_many :user_ucb_class_matches
  has_many :ucb_class_holds

  def url
    "https://newyork.ucbtrainingcenter.com#{registration_url}"
  end
end
