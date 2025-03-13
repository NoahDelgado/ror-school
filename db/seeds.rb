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

puts "Seeding database..."

# Create statuses
puts "Creating statuses..."
active_status = Status.create!(slug: 'active', title: 'Active')
inactive_status = Status.create!(slug: 'inactive', title: 'Inactive')
pending_status = Status.create!(slug: 'pending', title: 'Pending')

# Create addresses
puts "Creating addresses..."
school_address = Address.create!(
  zip: '12345',
  town: 'School Town',
  street: 'School Street',
  number: '123'
)

teacher_address = Address.create!(
  zip: '12346',
  town: 'Teacher Town',
  street: 'Teacher Street',
  number: '456'
)

student_address = Address.create!(
  zip: '12347',
  town: 'Student Town',
  street: 'Student Street',
  number: '789'
)

# Create rooms
puts "Creating rooms..."
rooms = [
  Room.create!(name: 'Room 101'),
  Room.create!(name: 'Room 102'),
  Room.create!(name: 'Room 103'),
  Room.create!(name: 'Laboratory'),
  Room.create!(name: 'Library')
]

# Create moments (time slots)
puts "Creating moments..."
moments = [
  Moment.create!(
    uid: 'MON-1',
    category: 0,
    start_at: Time.now.change(hour: 8),
    end_at: Time.now.change(hour: 9, min: 30)
  ),
  Moment.create!(
    uid: 'MON-2',
    category: 0,
    start_at: Time.now.change(hour: 10),
    end_at: Time.now.change(hour: 11, min: 30)
  )
]

# Create subjects
puts "Creating subjects..."
subjects = [
  Subject.create!(name: 'Mathematics'),
  Subject.create!(name: 'Physics'),
  Subject.create!(name: 'Chemistry'),
  Subject.create!(name: 'Biology'),
  Subject.create!(name: 'History')
]

# Create dean first as they will be referenced by school classes
puts "Creating dean..."
dean = Person.create!(
  email: 'dean@school.com',
  password: 'password123',
  password_confirmation: 'password123',
  username: 'dean',
  firstname: 'John',
  lastname: 'Dean',
  phone_number: '123-456-7890',
  type: 'Dean',
  address: school_address,
  status: active_status
)

# Create sections first (they are independent)
puts "Creating sections..."
sections = [
  Section.create!(name: "Science Section"),
  Section.create!(name: "Arts Section")
]

# Create school classes with sections
puts "Creating school classes..."
school_classes = [
  SchoolClass.create!(
    uid: 'CLASS-10A',
    name: 'Class 10A',
    person: dean,
    room: rooms[0],
    moment: moments[0],
    section: sections[0]  # Science section
  ),
  SchoolClass.create!(
    uid: 'CLASS-10B',
    name: 'Class 10B',
    person: dean,
    room: rooms[1],
    moment: moments[1],
    section: sections[1]  # Arts section
  )
]

puts "Creating teachers..."
teachers = [
  Person.create!(
    email: 'math.teacher@school.com',
    password: 'password123',
    password_confirmation: 'password123',
    username: 'mathteacher',
    firstname: 'Mary',
    lastname: 'Mathematics',
    phone_number: '123-456-7891',
    type: 'Teacher',
    address: teacher_address,
    status: active_status
  ),
  Person.create!(
    email: 'physics.teacher@school.com',
    password: 'password123',
    password_confirmation: 'password123',
    username: 'physteacher',
    firstname: 'Peter',
    lastname: 'Physics',
    phone_number: '123-456-7892',
    type: 'Teacher',
    address: teacher_address,
    status: active_status
  )
]

puts "Creating students..."
students = [
  Person.create!(
    email: 'student1@school.com',
    password: 'password123',
    password_confirmation: 'password123',
    username: 'student1',
    firstname: 'Sarah',
    lastname: 'Student',
    phone_number: '123-456-7893',
    type: 'Student',
    address: student_address,
    status: active_status
  ),
  Person.create!(
    email: 'student2@school.com',
    password: 'password123',
    password_confirmation: 'password123',
    username: 'student2',
    firstname: 'Mike',
    lastname: 'Student',
    phone_number: '123-456-7894',
    type: 'Student',
    address: student_address,
    status: active_status
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
    moment: moments[0],
    person: teachers[0]
  ),
  Course.create!(
    start_at: Time.now,
    end_at: Time.now + 4.months,
    week_day: 2,
    school_class: school_classes[0],
    subject: subjects[1],
    moment: moments[1],
    person: teachers[1]
  )
]

# Create examinations
puts "Creating examinations..."
examinations = courses.map do |course|
  Examination.create!(
    title: "#{course.subject.name} Midterm",
    expected_at: Time.now + 2.months,
    course: course
  )
end

# Create grades
puts "Creating grades..."
students.each do |student|
  examinations.each do |exam|
    Grade.create!(
      value: rand(60..100),
      expected_at: exam.expected_at,
      person: student,
      examination: exam
    )
  end
end

puts "Seed completed successfully!"
puts "\nLogin credentials:"
puts "\nDean:"
puts "Email: dean@school.com"
puts "Password: password123"
puts "\nTeachers:"
puts "Math Teacher - Email: math.teacher@school.com, Password: password123"
puts "Physics Teacher - Email: physics.teacher@school.com, Password: password123"
puts "\nStudents:"
puts "Student 1 - Email: student1@school.com, Password: password123"
puts "Student 2 - Email: student2@school.com, Password: password123"
