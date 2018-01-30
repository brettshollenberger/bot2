class UserUcbClassMatch < ApplicationRecord
  belongs_to :user
  belongs_to :ucb_class

  scope :available, -> { joins(:ucb_class).where("ucb_classes.available = ?", true) }
end
