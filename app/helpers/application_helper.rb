module ApplicationHelper
  def navigation_partial
    return unless current_person

    case current_person.class.name.downcase
    when "dean"
      "shared/nav_dean"
    when "teacher"
      "shared/nav_teacher"
    when "student"
      "shared/nav_student"
    end
  end

  def format_week_day(day)
    return "" if day.blank?
    days = {
      1 => "Monday",
      2 => "Tuesday",
      3 => "Wednesday",
      4 => "Thursday",
      5 => "Friday",
      6 => "Saturday",
      7 => "Sunday"
    }
    days[day.to_i] || day.to_s
  end
end
