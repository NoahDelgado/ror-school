module ApplicationHelper
  def navigation_partial
    return unless current_person
    
    case current_person.class.name.downcase
    when 'dean'
      'shared/nav_dean'
    when 'teacher'
      'shared/nav_teacher'
    when 'student'
      'shared/nav_student'
    end
  end
end
