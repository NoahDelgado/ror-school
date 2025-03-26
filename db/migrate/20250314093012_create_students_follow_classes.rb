class CreateStudentsFollowClasses < ActiveRecord::Migration[8.0]
  def change
    create_table :students_follow_classes do |t|
      t.references :student, null: false
      t.references :school_class, null: false, foreign_key: true

      t.index [:student_id, :school_class_id], unique: true
    end

    add_foreign_key :students_follow_classes, :people, column: :student_id
  end
end
