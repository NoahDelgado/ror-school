class Student < Person
    has_and_belongs_to_many :school_classes, join_table: "students_follow_classes"
    has_many :grades
end
