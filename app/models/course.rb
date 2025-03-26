class Course < ApplicationRecord
  include SoftDeletable

  belongs_to :school_class
  belongs_to :subject
  belongs_to :moment
  belongs_to :person
  has_many :examinations
  has_many :sections

  # Weekday scope - only courses on weekdays (Monday to Friday)
  scope :weekdays, -> { where(week_day: 1..5) }

  # Validation for week_day to ensure it's a weekday
  validates :week_day, inclusion: { in: 1..5, message: "must be a weekday (Monday to Friday)" }
end
