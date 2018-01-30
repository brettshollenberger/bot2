class UcbClassDate < ApplicationRecord
  belongs_to :ucb_class, inverse_of: :dates
end
