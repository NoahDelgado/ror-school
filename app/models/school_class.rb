class SchoolClass < ApplicationRecord
  include SoftDeletable

  belongs_to :person
  belongs_to :room
  belongs_to :moment
  belongs_to :section
  belongs_to :master, class_name: "Teacher", optional: true
  has_and_belongs_to_many :students,
                         class_name: "Student",
                         join_table: "students_follow_classes",
                         foreign_key: "school_class_id",
                         association_foreign_key: "student_id"
  has_many :courses
end
