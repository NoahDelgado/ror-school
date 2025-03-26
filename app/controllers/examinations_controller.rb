class ExaminationsController < ApplicationController
  before_action :authenticate_person!
  before_action :set_examination, only: %i[ show edit update destroy ]
  before_action :ensure_can_modify!, only: %i[ edit update destroy ]

  # GET /examinations or /examinations.json
  def index
    @examinations = if current_person.is_a?(Teacher)
      Examination.joins(:course).where(courses: { person_id: current_person.id })
    else
      Examination.all
    end
  end

  # GET /examinations/1 or /examinations/1.json
  def show
  end

  # GET /examinations/new
  def new
    @examination = Examination.new
  end

  # GET /examinations/1/edit
  def edit
  end

  # POST /examinations or /examinations.json
  def create
    @examination = Examination.new(examination_params)

    respond_to do |format|
      if @examination.save
        format.html { redirect_to @examination, notice: "Examination was successfully created." }
        format.json { render :show, status: :created, location: @examination }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @examination.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /examinations/1 or /examinations/1.json
  def update
    respond_to do |format|
      if @examination.update(examination_params)
        format.html { redirect_to @examination, notice: "Examination was successfully updated." }
        format.json { render :show, status: :ok, location: @examination }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @examination.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /examinations/1 or /examinations/1.json
  def destroy
    @examination.soft_delete

    respond_to do |format|
      format.html { redirect_to examinations_path, notice: "Examination was successfully archived." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_examination
      @examination = Examination.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def examination_params
      params.require(:examination).permit(:title, :expected_at, :course_id)
    end

    def ensure_can_modify!
      unless current_person.is_a?(Dean) || (current_person.is_a?(Teacher) && @examination.course.person_id == current_person.id)
        redirect_to examinations_path, alert: "You are not authorized to modify this examination."
      end
    end
end
