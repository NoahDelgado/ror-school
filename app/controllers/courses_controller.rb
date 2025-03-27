class CoursesController < ApplicationController
  before_action :authenticate_person!
  before_action :set_course, only: %i[ show edit update destroy ]
  before_action :authorize_course_access, only: %i[ index ]
  before_action :authorize_course_management, only: %i[ new create edit update destroy ]
  before_action :process_time_fields, only: %i[ create update ]

  # GET /courses or /courses.json
  def index
    @courses = if current_person.is_a?(Teacher)
      Course.where(person_id: current_person.id)
    else
      Course.all
    end
  end

  # GET /courses/1 or /courses/1.json
  def show
  end

  # GET /courses/new
  def new
    @course = Course.new
    @teachers = Teacher.all
    @subjects = Subject.all
    @moments = Moment.all
    @school_classes = SchoolClass.all
  end

  # GET /courses/1/edit
  def edit
    @teachers = Teacher.all
    @subjects = Subject.all
    @moments = Moment.all
    @school_classes = SchoolClass.all
  end

  # POST /courses or /courses.json
  def create
    @course = Course.new(course_params)
    normalize_times(@course)

    respond_to do |format|
      if @course.save
        format.html { redirect_to course_url(@course), notice: "Course was successfully created." }
        format.json { render :show, status: :created, location: @course }
      else
        @teachers = Teacher.all
        @subjects = Subject.all
        @moments = Moment.all
        @school_classes = SchoolClass.all
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @course.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /courses/1 or /courses/1.json
  def update
    @course.assign_attributes(course_params)
    normalize_times(@course)

    respond_to do |format|
      if @course.save
        format.html { redirect_to course_url(@course), notice: "Course was successfully updated." }
        format.json { render :show, status: :ok, location: @course }
      else
        @teachers = Teacher.all
        @subjects = Subject.all
        @moments = Moment.all
        @school_classes = SchoolClass.all
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @course.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /courses/1 or /courses/1.json
  def destroy
    @course.soft_delete

    respond_to do |format|
      format.html { redirect_to courses_path, notice: "Course was successfully archived." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_course
      @course = Course.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def course_params
      params.require(:course).permit(:start_at, :end_at, :week_day, :school_class_id, :subject_id, :moment_id, :person_id)
    end

    # Process time fields to handle time_field inputs
    def process_time_fields
      if params[:course][:start_at].present? && params[:course][:start_at].is_a?(String) && !params[:course][:start_at].include?("T")
        # If the input is just a time (no date part), add today's date
        time = params[:course][:start_at]
        params[:course][:start_at] = "#{Time.zone.today} #{time}"
      end

      if params[:course][:end_at].present? && params[:course][:end_at].is_a?(String) && !params[:course][:end_at].include?("T")
        # If the input is just a time (no date part), add today's date
        time = params[:course][:end_at]
        params[:course][:end_at] = "#{Time.zone.today} #{time}"
      end

      # Ensure week_day is a weekday (1-5)
      if params[:course][:week_day].present?
        day = params[:course][:week_day].to_i
        unless (1..5).include?(day)
          params[:course][:week_day] = 1 # Default to Monday if invalid
        end
      end
    end

    # Remove seconds and milliseconds from time fields
    def normalize_times(course)
      course.start_at = course.start_at.change(sec: 0, usec: 0) if course.start_at
      course.end_at = course.end_at.change(sec: 0, usec: 0) if course.end_at
    end

    # Ensure proper authorization for course access
    def authorize_course_access
      unless current_person.is_a?(Teacher) || current_person.is_a?(Dean)
        redirect_to root_path, alert: "You are not authorized to access courses."
      end
    end

    # Ensure only deans can manage courses
    def authorize_course_management
      unless current_person.is_a?(Dean)
        redirect_to courses_path, alert: "Only deans can create or modify courses."
      end
    end
end
