class Student < Person
    has_and_belongs_to_many :school_classes,
                           join_table: "students_follow_classes",
                           foreign_key: "student_id",
                           association_foreign_key: "school_class_id"
    has_many :grades
end
