class GradesController < ApplicationController
  before_action :authenticate_person!
  before_action :set_grade, only: %i[ show edit update destroy ]
  before_action :set_student, only: %i[ student_grades ]
  before_action :authorize_teacher_or_dean, only: %i[ new create edit update destroy ]
  before_action :authorize_for_grade, only: %i[ show ]

  # GET /grades or /grades.json
  def index
    @grades = if current_person.is_a?(Student)
      Grade.where(person_id: current_person.id)
    elsif current_person.is_a?(Teacher)
      Grade.joins(examination: { course: :school_class })
           .where(courses: { person_id: current_person.id, deleted_at: nil })
           .where(examinations: { deleted_at: nil })
           .where(school_classes: { deleted_at: nil })
    else
      Grade.all
    end
  end

  # GET /students/:student_id/grades
  def student_grades
    authorize_teacher_for_student
    @grades = Grade.joins(examination: :course)
                  .where(person_id: @student.id,
                        courses: { person_id: current_person.id, deleted_at: nil },
                        examinations: { deleted_at: nil })
    render :index
  end

  # GET /grades/1 or /grades/1.json
  def show
  end

  # GET /grades/new
  def new
    @grade = Grade.new
    @grade.person_id = params[:student_id] if params[:student_id]
    @grade.examination_id = params[:examination_id] if params[:examination_id]
  end

  # GET /grades/1/edit
  def edit
  end

  # POST /grades or /grades.json
  def create
    @grade = Grade.new(grade_params)
    return unless authorize_teacher_for_grade

    respond_to do |format|
      if @grade.save
        format.html { redirect_to grade_url(@grade), notice: "Grade was successfully created." }
        format.json { render :show, status: :created, location: @grade }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @grade.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /grades/1 or /grades/1.json
  def update
    return unless authorize_teacher_for_grade

    respond_to do |format|
      if @grade.update(grade_params)
        format.html { redirect_to grade_url(@grade), notice: "Grade was successfully updated." }
        format.json { render :show, status: :ok, location: @grade }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @grade.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /grades/1 or /grades/1.json
  def destroy
    return unless authorize_teacher_for_grade
    @grade.soft_delete

    respond_to do |format|
      format.html { redirect_to grades_url, notice: "Grade was successfully archived." }
      format.json { head :no_content }
    end
  end

  private
    def set_student
      @student = Student.find(params[:student_id])
    end

    def authorize_for_grade
      # Students can only view their own grades
      if current_person.is_a?(Student)
        unless @grade.person_id == current_person.id
          redirect_to grades_path, alert: "You are not authorized to view this grade."
        end
      end
    end

    def authorize_teacher_for_student
      unless current_person.is_a?(Teacher) &&
             SchoolClass.joins(:courses)
                       .where(courses: { person_id: current_person.id, deleted_at: nil })
                       .where(school_classes: { deleted_at: nil })
                       .joins(:students)
                       .where(students: { id: @student.id })
                       .exists?
        redirect_to root_path, alert: "You are not authorized to view these grades."
      end
    end

    def authorize_teacher_or_dean
      unless current_person.is_a?(Teacher) || current_person.is_a?(Dean)
        redirect_to root_path, alert: "You are not authorized to manage grades."
      end
    end

    def authorize_teacher_for_grade
      unless current_person.is_a?(Teacher) &&
             Examination.joins(:course)
                       .where(courses: { person_id: current_person.id, deleted_at: nil })
                       .where(examinations: { deleted_at: nil })
                       .where(id: @grade.examination_id)
                       .exists?
        redirect_to root_path, alert: "You are not authorized to manage this grade."
        return false
      end
      true
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_grade
      @grade = Grade.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def grade_params
      params.require(:grade).permit(:value, :expected_at, :examination_id, :person_id)
    end
end
