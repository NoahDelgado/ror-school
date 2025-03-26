class Moment < ApplicationRecord
  include SoftDeletable

  PERIOD_TYPES = [ "QUARTER", "SEMESTER", "YEAR" ]

  validates :period_type, presence: true, inclusion: { in: PERIOD_TYPES }
  validates :year, presence: true, numericality: { only_integer: true }
  validates :period_number, presence: true, numericality: { only_integer: true }
  validate :valid_period_number_for_type

  def display_time
    if start_at.present? && end_at.present?
      "#{start_at.strftime('%H:%M')} - #{end_at.strftime('%H:%M')}"
    else
      uid
    end
  end

  def category_name
    case category
    when 0 then "Morning"
    when 1 then "Afternoon"
    when 2 then "Evening"
    else "Unknown"
    end
  end

  def display_name
    case period_type
    when "QUARTER"
      "Q#{period_number} #{year}"
    when "SEMESTER"
      "S#{period_number} #{year}"
    when "YEAR"
      year.to_s
    end
  end

  private

  def valid_period_number_for_type
    max_period = case period_type
    when "QUARTER" then 4
    when "SEMESTER" then 2
    when "YEAR" then 1
    end

    if period_number.present? && (period_number < 1 || period_number > max_period)
      errors.add(:period_number, "must be between 1 and #{max_period} for #{period_type}")
    end
  end
end
