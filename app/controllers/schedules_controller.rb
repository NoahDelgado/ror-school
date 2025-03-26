class SchedulesController < ApplicationController
  before_action :authenticate_person!

  def index
    # Get current date and week range
    @date = params[:date] ? Date.parse(params[:date]) : Date.today
    @week_start = @date.beginning_of_week
    @week_end = @date.end_of_week

    # Find the current moment based on date
    @current_moment = find_current_moment(@date)

    # Base query for courses
    base_query = Course.includes(:subject, :school_class, :moment, :person, school_class: :room)
                       .where(deleted_at: nil)

    # Filter by current moment automatically
    base_query = base_query.where(moment_id: @current_moment.id) if @current_moment

    # Get courses based on the user type
    @courses = if current_person.is_a?(Teacher)
      # For teachers, get their own courses
      base_query.where(person_id: current_person.id)
    elsif current_person.is_a?(Student)
      # For students, get courses from their classes
      base_query.joins(school_class: :students)
               .where(students: { id: current_person.id })
               .distinct
    else
      # For others (like Dean), get all courses
      base_query
    end

    # Create a schedule hash organized by day and time
    @schedule = {}
    [ 1, 2, 3, 4, 5 ].each do |day|
      @schedule[day] = @courses.select { |course| course.week_day == day }
                              .sort_by { |course| [ course.start_at.hour, course.start_at.min, course.end_at.hour, course.end_at.min ] }
    end

    # Generate time slots for the timetable
    @time_slots = generate_time_slots(7, 20) # From 7:00 to 20:00

    # Days of the week
    @days_of_week = {
      1 => "Monday",
      2 => "Tuesday",
      3 => "Wednesday",
      4 => "Thursday",
      5 => "Friday"
    }

    # Get color assignments for courses (to consistently color by subject)
    @subject_colors = {}
    subjects = @courses.map { |c| c.subject }.uniq
    colors = [
      "rgba(72, 199, 142, 0.85)",  # Green
      "rgba(72, 95, 199, 0.85)",   # Blue
      "rgba(199, 72, 153, 0.85)",  # Pink
      "rgba(199, 121, 72, 0.85)",  # Orange
      "rgba(176, 72, 199, 0.85)",  # Purple
      "rgba(199, 72, 72, 0.85)",   # Red
      "rgba(72, 199, 199, 0.85)",  # Teal
      "rgba(170, 199, 72, 0.85)"   # Lime
    ]

    subjects.each_with_index do |subject, index|
      @subject_colors[subject.id] = colors[index % colors.length]
    end
  end

  private

  def generate_time_slots(start_hour, end_hour)
    (start_hour..end_hour).map do |hour|
      Time.new(Time.current.year, 1, 1, hour, 0, 0)
    end
  end

  def find_current_moment(date)
    year = date.year
    month = date.month

    # Determine current period based on date
    case month
    when 1..3   # Jan-Mar: Q1 or S1
      quarter = 1
      semester = 1
    when 4..6   # Apr-Jun: Q2 or S1
      quarter = 2
      semester = 1
    when 7..9   # Jul-Sep: Q3 or S2
      quarter = 3
      semester = 2
    when 10..12 # Oct-Dec: Q4 or S2
      quarter = 4
      semester = 2
    end

    # Try to find the moment in this order: Quarter, Semester, Year
    moment = Moment.find_by(period_type: "QUARTER", year: year, period_number: quarter) ||
             Moment.find_by(period_type: "SEMESTER", year: year, period_number: semester) ||
             Moment.find_by(period_type: "YEAR", year: year)

    # If no moment found for current year, try to find the most recent one
    moment || Moment.order(year: :desc, period_type: :asc, period_number: :desc).first
  end
end
