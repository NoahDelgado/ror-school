class SchoolClassesController < ApplicationController
  before_action :authenticate_person!
  before_action :set_school_class, only: %i[ show edit update destroy manage_students update_students ]
  before_action :ensure_dean!, only: %i[ new create edit update destroy manage_students update_students management ]

  # GET /school_classes/management
  def management
    ensure_dean!
    @school_classes = SchoolClass.includes(:person, :room, :section, :moment, :students)
                                .order("moments.year DESC, school_classes.name ASC")
                                .references(:moments)
    @sections = Section.all
    @rooms = Room.all
    @teachers = Teacher.all
    @moments = Moment.all
  end

  # GET /school_classes or /school_classes.json
  def index
    @school_classes = if current_person.is_a?(Teacher)
      SchoolClass.joins(:courses).where(courses: { person_id: current_person.id }).distinct
    elsif current_person.is_a?(Student)
      current_person.school_classes
    else
      SchoolClass.all
    end
  end

  # GET /school_classes/1 or /school_classes/1.json
  def show
    @students = @school_class.students
    @courses = if current_person.is_a?(Teacher)
      @school_class.courses.where(person_id: current_person.id)
    else
      @school_class.courses
    end

    # Ensure students can only view their own classes
    if current_person.is_a?(Student)
      unless current_person.school_classes.include?(@school_class)
        redirect_to school_classes_path, alert: "You don't have access to this class."
        nil
      end
    end
  end

  # GET /school_classes/new
  def new
    @school_class = SchoolClass.new
  end

  # GET /school_classes/1/edit
  def edit
  end

  # GET /school_classes/1/manage_students
  def manage_students
    @available_students = Student.all
    @assigned_students = @school_class.students
  end

  # POST /school_classes/1/update_students
  def update_students
    student_ids = params[:student_ids] || []

    # Update the students for this class
    @school_class.student_ids = student_ids

    respond_to do |format|
      if @school_class.save
        format.html { redirect_to school_class_url(@school_class), notice: "Students were successfully updated." }
      else
        @available_students = Student.all
        @assigned_students = @school_class.students
        format.html { render :manage_students, status: :unprocessable_entity }
      end
    end
  end

  # POST /school_classes or /school_classes.json
  def create
    @school_class = SchoolClass.new(school_class_params)

    respond_to do |format|
      if @school_class.save
        format.html { redirect_to school_class_url(@school_class), notice: "School class was successfully created." }
        format.json { render :show, status: :created, location: @school_class }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @school_class.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /school_classes/1 or /school_classes/1.json
  def update
    respond_to do |format|
      if @school_class.update(school_class_params)
        format.html { redirect_to school_class_url(@school_class), notice: "School class was successfully updated." }
        format.json { render :show, status: :ok, location: @school_class }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @school_class.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /school_classes/1 or /school_classes/1.json
  def destroy
    @school_class.soft_delete
    respond_to do |format|
      format.html { redirect_to school_classes_url, notice: "School class was successfully archived." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_school_class
      @school_class = SchoolClass.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def school_class_params
      params.require(:school_class).permit(:uid, :name, :person_id, :room_id, :moment_id, :section_id, student_ids: [])
    end

    def ensure_dean!
      unless current_person.is_a?(Dean)
        redirect_to school_classes_path, alert: "Only deans can modify school classes."
      end
    end
end
