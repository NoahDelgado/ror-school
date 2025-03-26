class StudentDashboardController < ApplicationController
  before_action :authenticate_person!
  before_action :ensure_student

  def index
    @grades = Grade.where(person_id: current_person.id)
                   .includes(examination: { course: :subject })
    @school_classes = current_person.school_classes

    # Group grades by subject
    @grades_by_subject = @grades.group_by { |grade| grade.examination.course.subject }

    # Calculate average grades per subject
    @average_by_subject = {}
    @grades_by_subject.each do |subject, grades|
      @average_by_subject[subject] = grades.map(&:value).sum / grades.size.to_f if grades.any?
    end

    # Calculate overall average
    @overall_average = @grades.any? ? @grades.map(&:value).sum / @grades.size.to_f : nil
  end

  private

  def ensure_student
    unless current_person.is_a?(Student)
      redirect_to root_path, alert: "You need to be a student to access this page."
    end
  end
end
