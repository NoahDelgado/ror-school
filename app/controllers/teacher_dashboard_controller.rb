class TeacherDashboardController < ApplicationController
  before_action :authenticate_person!
  before_action :ensure_teacher

  def index
    @courses = Course.where(person_id: current_person.id)
                    .includes(:school_class, :subject, :examinations)

    # Get all examinations for teacher's courses
    @examinations = Examination.where(course_id: @courses.pluck(:id))
                              .includes(:grades)

    # Get upcoming examinations (scheduled within the next 14 days)
    @upcoming_examinations = @examinations.where("expected_at >= ? AND expected_at <= ?",
                                            Date.today, 14.days.from_now)
                                       .order(expected_at: :asc)

    # Count grades that need to be reviewed (no value assigned yet)
    @grades_to_review = Grade.where(examination_id: @examinations.pluck(:id))
                            .where(value: nil)
                            .count

    # Get course statistics
    @courses_statistics = @courses.map do |course|
      course_exams = course.examinations
      course_grades = Grade.where(examination_id: course_exams.pluck(:id))

      {
        course: course,
        exams_count: course_exams.count,
        students_count: course.school_class.students.count,
        average_grade: course_grades.where.not(value: nil).any? ?
                      course_grades.where.not(value: nil).average(:value).to_f.round(1) : nil
      }
    end
  end

  private

  def ensure_teacher
    unless current_person.is_a?(Teacher)
      redirect_to root_path, alert: "You need to be a teacher to access this page."
    end
  end
end
