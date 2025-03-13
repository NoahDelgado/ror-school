class FixCourseClassReference < ActiveRecord::Migration[8.0]
  def change
    remove_reference :courses, :classe, foreign_key: true
    add_reference :courses, :school_class, null: false, foreign_key: true
    add_reference :school_classes, :section, null: false, foreign_key: true
  end
end
