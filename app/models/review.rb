class Review < ApplicationRecord
  belongs_to :recipe
  belongs_to :user

  validates :rating, presence: true
  validates :rating, numericality: { less_than_or_equal_to: 5, message: I18n.t('.out_of_range_error') }

end