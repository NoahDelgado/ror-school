class DeanDashboardController < ApplicationController
  before_action :authenticate_person!
  before_action :ensure_dean

  def index
    @courses = Course.all
    @teachers = Teacher.all
    @students = Student.all
    @moments = Moment.all
  end

  def manage_courses
    @courses = Course.all
    @teachers = Teacher.all
    @subjects = Subject.all
    @moments = Moment.all
    @school_classes = SchoolClass.all
  end

  def course_history
    # Get all moments ordered by year and period
    @moments = Moment.all.order(year: :desc, period_number: :desc)

    # Set selected moment from params or default to most recent
    @selected_moment = if params[:moment_id]
      Moment.find(params[:moment_id])
    else
      @moments.first
    end

    if @selected_moment
      # Get all courses for the selected moment including soft-deleted ones
      @courses = Course.unscoped
                     .where(moment_id: @selected_moment.id)
                     .includes(:subject, :school_class, :person)
                     .order("subjects.name")

      # Calculate statistics for the selected moment
      @stats = {
        total_courses: @courses.count,
        active_courses: @courses.where(deleted_at: nil).count,
        archived_courses: @courses.where.not(deleted_at: nil).count,
        teachers_count: @courses.map(&:person_id).uniq.count,
        subjects_count: @courses.map(&:subject_id).uniq.count,
        school_classes_count: @courses.map(&:school_class_id).uniq.count
      }
    end
  end

  def manage_bulletins
    @moments = Moment.all
    @school_classes = SchoolClass.all

    # Handle search/filtering
    @students = Student.all
    if params[:search].present?
      @students = @students.where("firstname LIKE ? OR lastname LIKE ?",
                                 "%#{params[:search]}%",
                                 "%#{params[:search]}%")
    end

    if params[:school_class_id].present?
      @students = @students.joins(:school_classes).where(school_classes: { id: params[:school_class_id] })
    end

    # Apply pagination if Kaminari is available
    if defined?(Kaminari)
      @students = @students.page(params[:page]).per(10)
    else
      # Limit results if no pagination
      @students = @students.limit(20)
    end
  end

  def student_bulletin
    @student = Student.find(params[:student_id])
    @moment = Moment.find(params[:moment_id])

    # Get all courses for the student's class in the specified moment
    @school_classes = @student.school_classes
    @courses = Course.where(school_class_id: @school_classes.pluck(:id), moment_id: @moment.id)

    # Get grades for this student in these courses
    @grades = Grade.joins(examination: :course)
                  .where(person_id: @student.id,
                         examinations: { deleted_at: nil },
                         courses: { id: @courses.pluck(:id), deleted_at: nil })
                  .includes(examination: :course)
  end

  private

  def ensure_dean
    unless current_person.is_a?(Dean)
      redirect_to root_path, alert: "You must be a dean to access this page."
    end
  end
end
