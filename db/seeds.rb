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

# Clear existing data
puts "Cleaning database..."
[ Grade, Examination, Course, SchoolClass, Person, Moment, Room, Section, Status, Subject, Address ].each(&:delete_all)

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
  Subject.create!(name: 'Literature')
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

teacher_address = Address.create!(
  zip: '23456',
  town: 'Teacher Town',
  street: 'Teacher Street',
  number: '456'
)

dean_address = Address.create!(
  zip: '45678',
  town: 'Dean Town',
  street: 'Dean Avenue',
  number: '101'
)

student_address = Address.create!(
  zip: '34567',
  town: 'Student Town',
  street: 'Student Street',
  number: '789'
)

# Create teachers
puts "Creating teachers..."
teachers = [
  Person.create!(
    email: 'math.teacher@school.com',
    password: 'password123',
    username: 'math_teacher',
    firstname: 'Math',
    lastname: 'Teacher',
    phone_number: '234-567-8901',
    iban: 'CH93 0076 2011 6238 4295 8',
    type: 'Teacher',
    address: teacher_address,
    status: statuses[:active]
  ),
  Person.create!(
    email: 'physics.teacher@school.com',
    password: 'password123',
    username: 'physics_teacher',
    firstname: 'Physics',
    lastname: 'Teacher',
    phone_number: '345-678-9012',
    iban: 'CH93 0076 2011 6238 4295 9',
    type: 'Teacher',
    address: teacher_address,
    status: statuses[:active]
  )
]

# Create dean
puts "Creating dean..."
dean = Person.create!(
  email: 'dean@school.com',
  password: 'password123',
  username: 'school_dean',
  firstname: 'Academic',
  lastname: 'Dean',
  phone_number: '123-456-7890',
  iban: 'CH93 0076 2011 6238 4295 7',
  type: 'Dean',
  address: dean_address,
  status: statuses[:active]
)

# Create students
puts "Creating students..."
students = [
  Person.create!(
    email: 'student1@school.com',
    password: 'password123',
    username: 'student1',
    firstname: 'First',
    lastname: 'Student',
    phone_number: '456-789-0123',
    iban: 'CH93 0076 2011 6238 4296 0',
    type: 'Student',
    address: student_address,
    status: statuses[:active]
  ),
  Person.create!(
    email: 'student2@school.com',
    password: 'password123',
    username: 'student2',
    firstname: 'Second',
    lastname: 'Student',
    phone_number: '567-890-1234',
    iban: 'CH93 0076 2011 6238 4296 1',
    type: 'Student',
    address: student_address,
    status: statuses[:active]
  )
]

# Create school classes
puts "Creating school classes..."
school_classes = [
  SchoolClass.create!(
    uid: 'CLASS-10A',
    name: 'Class 10A',
    person: teachers[0],
    room: rooms[0],
    moment: year_period,
    section: sections[0]
  ),
  SchoolClass.create!(
    uid: 'CLASS-10B',
    name: 'Class 10B',
    person: teachers[1],
    room: rooms[1],
    moment: year_period,
    section: sections[1]
  ),
  SchoolClass.create!(
    uid: 'CLASS-10C',
    name: 'Class 10C',
    person: teachers[0],
    room: rooms[2],
    moment: year_period,
    section: sections[2]
  )
]

# Create courses
puts "Creating courses..."
courses = [
  Course.create!(
    start_at: Time.now,
    end_at: Time.now + 4.months,
    week_day: 1,
    school_class: school_classes[0],
    subject: subjects[0],
    moment: quarters[0],
    person: teachers[0]
  ),
  Course.create!(
    start_at: Time.now,
    end_at: Time.now + 4.months,
    week_day: 2,
    school_class: school_classes[0],
    subject: subjects[1],
    moment: quarters[0],
    person: teachers[1]
  ),
  Course.create!(
    start_at: Time.now,
    end_at: Time.now + 4.months,
    week_day: 3,
    school_class: school_classes[1],
    subject: subjects[2],
    moment: quarters[1],
    person: teachers[0]
  ),
  Course.create!(
    start_at: Time.now,
    end_at: Time.now + 4.months,
    week_day: 4,
    school_class: school_classes[1],
    subject: subjects[3],
    moment: quarters[1],
    person: teachers[1]
  )
]

# Create examinations
puts "Creating examinations..."
examinations = courses.map do |course|
  Examination.create!(
    title: "#{course.subject.name} Exam",
    expected_at: Time.now + 2.months,
    course: course
  )
end

# Create grades
puts "Creating grades..."
examinations.each do |exam|
  students.each do |student|
    Grade.create!(
      value: (rand(2.0..6.0) * 2).round / 2.0, # This will give values like 1.0, 1.5, 2.0, etc.
      expected_at: Time.now + 2.months,
      examination: exam,
      person: student
    )
  end
end

# Associate students with classes
puts "Associating students with classes..."
school_classes.each do |school_class|
  students.each do |student|
    school_class.students << student
  end
end

puts "Seeds completed successfully!"
puts "\nLogin credentials:"
puts "Dean:"
puts "- dean@school.com / password123"
puts "Teachers:"
puts "- math.teacher@school.com / password123"
puts "- physics.teacher@school.com / password123"
puts "Students:"
puts "- student1@school.com / password123"
puts "- student2@school.com / password123"
