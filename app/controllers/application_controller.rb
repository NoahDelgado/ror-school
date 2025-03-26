class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  protected

  def ensure_dean!
    unless current_person.is_a?(Dean)
      redirect_to root_path, alert: "You are not authorized to access this page."
    end
  end
end
