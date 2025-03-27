# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# This file contains all necessary seed data for the school system

# Clear existing data - order matters for foreign key constraints
puts "Cleaning database..."
begin
  ActiveRecord::Base.connection.execute("PRAGMA foreign_keys = OFF;")

  # Delete in proper order to avoid foreign key constraint issues
  Grade.delete_all
  Examination.delete_all
  Course.delete_all

  # Delete join table records for students and classes
  ActiveRecord::Base.connection.execute("DELETE FROM students_follow_classes")

  SchoolClass.delete_all
  Person.delete_all
  Moment.delete_all
  Room.delete_all
  Section.delete_all
  Status.delete_all
  Subject.delete_all
  Address.delete_all

  ActiveRecord::Base.connection.execute("PRAGMA foreign_keys = ON;")
rescue => e
  puts "Error during cleanup: #{e.message}"
end

# Create Statuses
puts "Creating statuses..."
statuses = {
  active: Status.create!(slug: 'active', title: 'Active'),
  inactive: Status.create!(slug: 'inactive', title: 'Inactive'),
  pending: Status.create!(slug: 'pending', title: 'Pending Approval')
}

# Create Rooms
puts "Creating rooms..."
rooms = [
  Room.create!(name: 'A101'),
  Room.create!(name: 'A102'),
  Room.create!(name: 'B201'),
  Room.create!(name: 'B202'),
  Room.create!(name: 'Computer Lab 1'),
  Room.create!(name: 'Science Lab')
]

# Create Sections
puts "Creating sections..."
sections = [
  Section.create!(name: 'Primary'),
  Section.create!(name: 'Secondary'),
  Section.create!(name: 'High School')
]

# Create Subjects
puts "Creating subjects..."
subjects = [
  Subject.create!(name: 'Mathematics'),
  Subject.create!(name: 'Physics'),
  Subject.create!(name: 'Chemistry'),
  Subject.create!(name: 'Biology'),
  Subject.create!(name: 'History'),
  Subject.create!(name: 'Literature'),
  Subject.create!(name: 'English'),
  Subject.create!(name: 'Computer Science'),
  Subject.create!(name: 'Geography'),
  Subject.create!(name: 'Economics')
]

# Create Moments (Academic Periods)
puts "Creating academic periods..."
current_year = Time.current.year

# Create Quarters for current year
quarters = (1..4).map do |quarter|
  start_month = 1 + (quarter-1)*3
  end_month = start_month + 2
  Moment.create!(
    uid: "Q#{quarter}-#{current_year}",
    period_type: "QUARTER",
    year: current_year,
    period_number: quarter,
    start_at: Time.new(current_year, start_month, 1),
    end_at: Time.new(current_year, end_month, Time.days_in_month(end_month, current_year))
  )
end

# Create Semesters for current year
semesters = (1..2).map do |semester|
  start_month = 1 + (semester-1)*6
  end_month = start_month + 5
  Moment.create!(
    uid: "S#{semester}-#{current_year}",
    period_type: "SEMESTER",
    year: current_year,
    period_number: semester,
    start_at: Time.new(current_year, start_month, 1),
    end_at: Time.new(current_year, end_month, Time.days_in_month(end_month, current_year))
  )
end

# Create Year period
year_period = Moment.create!(
  uid: "Y-#{current_year}",
  period_type: "YEAR",
  year: current_year,
  period_number: 1,
  start_at: Time.new(current_year, 1, 1),
  end_at: Time.new(current_year, 12, 31)
)

# Create addresses
puts "Creating addresses..."
school_address = Address.create!(
  zip: '12345',
  town: 'School Town',
  street: 'School Street',
  number: '123'
)

addresses = {
  teacher: Address.create!(
    zip: '23456',
    town: 'Teacher Town',
    street: 'Teacher Street',
    number: '456'
  ),
  dean: Address.create!(
    zip: '45678',
    town: 'Dean Town',
    street: 'Dean Avenue',
    number: '101'
  ),
  student: Address.create!(
    zip: '34567',
    town: 'Student Town',
    street: 'Student Street',
    number: '789'
  ),
  admin: Address.create!(
    zip: '56789',
    town: 'Admin Town',
    street: 'Admin Avenue',
    number: '202'
  )
}

# Create administrator
puts "Creating administrator..."
admin = Administrator.where(email: 'admin@school.com').first_or_initialize.tap do |admin|
  admin.password = 'password123'
  admin.username = 'school_admin'
  admin.firstname = 'System'
  admin.lastname = 'Administrator'
  admin.phone_number = '111-222-3333'
  admin.iban = 'CH93 0076 2011 6238 4295 6'
  admin.address = addresses[:admin]
  admin.status = statuses[:active]
  admin.save!
end

# Create dean
puts "Creating dean..."
dean = Dean.where(email: 'dean@school.com').first_or_initialize.tap do |dean|
  dean.password = 'password123'
  dean.username = 'school_dean'
  dean.firstname = 'Academic'
  dean.lastname = 'Dean'
  dean.phone_number = '123-456-7890'
  dean.iban = 'CH93 0076 2011 6238 4295 7'
  dean.address = addresses[:dean]
  dean.status = statuses[:active]
  dean.save!
end

# Create teachers
puts "Creating teachers..."
teachers = []

[
  {
    email: 'math.teacher@school.com',
    username: 'math_teacher',
    firstname: 'Math',
    lastname: 'Teacher',
    phone_number: '234-567-8901',
    iban: 'CH93 0076 2011 6238 4295 8'
  },
  {
    email: 'physics.teacher@school.com',
    username: 'physics_teacher',
    firstname: 'Physics',
    lastname: 'Teacher',
    phone_number: '345-678-9012',
    iban: 'CH93 0076 2011 6238 4295 9'
  },
  {
    email: 'english.teacher@school.com',
    username: 'english_teacher',
    firstname: 'English',
    lastname: 'Teacher',
    phone_number: '456-789-0123',
    iban: 'CH93 0076 2011 6238 4296 0'
  },
  {
    email: 'compsci.teacher@school.com',
    username: 'compsci_teacher',
    firstname: 'Computer',
    lastname: 'Science',
    phone_number: '567-890-1234',
    iban: 'CH93 0076 2011 6238 4296 1'
  }
].each do |teacher_attrs|
  teacher = Teacher.where(email: teacher_attrs[:email]).first_or_initialize
  teacher.attributes = teacher_attrs.merge(
    password: 'password123',
    address: addresses[:teacher],
    status: statuses[:active]
  )
  teacher.save!
  teachers << teacher
end

# Create students
puts "Creating students..."
students = []

20.times do |i|
  email = "student#{i+1}@school.com"
  student = Student.where(email: email).first_or_initialize

  student.attributes = {
    password: 'password123',
    username: "student#{i+1}",
    firstname: [ "Alex", "Jordan", "Taylor", "Casey", "Morgan", "Riley", "Jamie", "Avery", "Quinn", "Skyler" ].sample,
    lastname: [ "Smith", "Johnson", "Williams", "Brown", "Jones", "Garcia", "Miller", "Davis", "Rodriguez", "Wilson" ].sample,
    phone_number: "#{100+i}-#{200+i}-#{300+i}",
    iban: "CH93 0076 2011 6238 #{4300+i}",
    address: addresses[:student],
    status: statuses[:active]
  }

  student.save!
  students << student
end

# Create school classes
puts "Creating school classes..."
school_classes = []

[
  {
    uid: 'CLASS-10A',
    name: 'Class 10A',
    teacher_index: 0,
    room_index: 0,
    section_index: 2 # High School
  },
  {
    uid: 'CLASS-9B',
    name: 'Class 9B',
    teacher_index: 1,
    room_index: 1,
    section_index: 2 # High School
  },
  {
    uid: 'CLASS-8C',
    name: 'Class 8C',
    teacher_index: 2,
    room_index: 2,
    section_index: 1 # Secondary
  },
  {
    uid: 'CLASS-6A',
    name: 'Class 6A',
    teacher_index: 3,
    room_index: 3,
    section_index: 1 # Secondary
  },
  {
    uid: 'CLASS-3B',
    name: 'Class 3B',
    teacher_index: 0,
    room_index: 4,
    section_index: 0 # Primary
  }
].each do |class_attrs|
  school_class = SchoolClass.where(uid: class_attrs[:uid]).first_or_initialize

  teacher = teachers[class_attrs[:teacher_index]]

  school_class.attributes = {
    name: class_attrs[:name],
    person: teacher,
    room: rooms[class_attrs[:room_index]],
    moment: year_period,
    section: sections[class_attrs[:section_index]]
  }

  school_class.save!
  school_classes << school_class
end

# Create courses
puts "Creating courses..."
courses = []

# Helper method to create realistic course schedules
def create_course_time(day_of_week, hour)
  start_time = Time.new(Time.current.year, Time.current.month, Time.current.day, hour, 0)
  end_time = start_time + 1.hour
  [ start_time, end_time, day_of_week ]
end

# Course schedule data: [day, hour]
schedules = [
  [ 1, 8 ], [ 1, 10 ], [ 1, 13 ], [ 1, 15 ], # Monday
  [ 2, 8 ], [ 2, 10 ], [ 2, 13 ], [ 2, 15 ], # Tuesday
  [ 3, 8 ], [ 3, 10 ], [ 3, 13 ], [ 3, 15 ], # Wednesday
  [ 4, 8 ], [ 4, 10 ], [ 4, 13 ], [ 4, 15 ], # Thursday
  [ 5, 8 ], [ 5, 10 ], [ 5, 13 ], [ 5, 15 ]  # Friday
]

# Clear existing courses
Course.delete_all

# Create courses for each class
school_classes.each do |school_class|
  # Assign relevant subjects based on section
  relevant_subjects = case school_class.section.name
  when 'Primary'
    subjects.sample(4) # Fewer subjects for primary
  when 'Secondary'
    subjects.sample(6) # More subjects for secondary
  when 'High School'
    subjects.sample(8) # Most subjects for high school
  end

  # Generate a unique identifier for the course based on class and subject
  relevant_subjects.each_with_index do |subject, index|
    # Select a schedule
    day, hour = schedules[index % schedules.length]
    start_time, end_time, week_day = create_course_time(day, hour)

    # Create a unique course identifier
    course_uid = "#{school_class.uid}-#{subject.name.gsub(/\s+/, '')}"

    # Create the course if it doesn't already exist
    course = Course.new(
      start_at: start_time,
      end_at: end_time,
      week_day: week_day,
      school_class: school_class,
      subject: subject,
      moment: [ quarters, semesters ].flatten.sample, # Assign to a random quarter or semester
      person: teachers.sample # Assign a random teacher
    )

    course.save!
    courses << course
  end
end

# Create examinations
puts "Creating examinations..."
examinations = []

# Clear existing examinations
Examination.delete_all

courses.each do |course|
  # Create 1-3 examinations per course
  rand(1..3).times do |i|
    # Create examination date within the course's academic period
    exam_date = course.moment.start_at + rand(7..60).days

    exam = Examination.new(
      title: "#{course.subject.name} Exam #{i+1}",
      expected_at: exam_date,
      course: course
    )

    exam.save!
    examinations << exam
  end
end

# Associate students with classes BEFORE creating grades
puts "Associating students with classes..."
# First clear existing associations
ActiveRecord::Base.connection.execute("DELETE FROM students_follow_classes")

# Distribute students among classes more realistically
student_groups = students.in_groups(school_classes.length, false)

school_classes.each_with_index do |school_class, index|
  student_group = student_groups[index] || []
  student_group.each do |student|
    school_class.students << student
  end
end

# Create grades
puts "Creating grades..."

# Clear existing grades
Grade.delete_all

examinations.each do |exam|
  # Get students from the associated class
  class_students = exam.course.school_class.students

  puts "Creating #{class_students.count} grades for examination: #{exam.title}"

  class_students.each do |student|
    # Create grade with realistic distribution
    grade_value = [ 1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0, 5.5, 6.0 ].sample

    # Weight higher grades more likely
    if rand < 0.7
      grade_value = [ 4.0, 4.5, 5.0, 5.5, 6.0 ].sample
    end

    grade = Grade.new(
      value: grade_value,
      expected_at: exam.expected_at,
      examination: exam,
      person: student
    )

    grade.save!
  end
end

puts "Seeds completed successfully!"
puts "\nLogin credentials:"
puts "Administrator:"
puts "- admin@school.com / password123"
puts "Dean:"
puts "- dean@school.com / password123"
puts "Teachers:"
puts "- math.teacher@school.com / password123"
puts "- physics.teacher@school.com / password123"
puts "- english.teacher@school.com / password123"
puts "- compsci.teacher@school.com / password123"
puts "Students:"
puts "- student1@school.com / password123"
puts "- student2@school.com / password123"
puts "- etc. (20 students total)"
