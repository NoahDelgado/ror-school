class HomeController < ApplicationController
  before_action :authenticate_person!

  def index
    # Redirect students to their dashboard
    if current_person.is_a?(Student)
      redirect_to student_dashboard_path
    # Redirect teachers to their dashboard
    elsif current_person.is_a?(Teacher)
      redirect_to teacher_dashboard_path
    # Redirect deans to their dashboard
    elsif current_person.is_a?(Dean)
      redirect_to dean_dashboard_index_path
    end
    # Keep the default page for other roles
  end
end
