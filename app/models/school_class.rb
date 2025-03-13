class SchoolClass < ApplicationRecord
  belongs_to :person
  belongs_to :room
  belongs_to :moment
  belongs_to :section
  belongs_to :master, class_name: "Teacher", optional: true
  has_and_belongs_to_many :students, class_name: "Student", join_table: "students_follow_classes"
  has_many :courses
end
