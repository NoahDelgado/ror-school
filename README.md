# ROR School Management System

A comprehensive web application built with Ruby on Rails 8 for managing school operations including students, teachers, classes, courses, examinations, and grades.

## Features

* **User Management**: Support for different user roles (Students, Teachers, Deans, Administrators)
* **Class Management**: Create and manage school classes with assigned teachers and rooms
* **Course Scheduling**: Schedule courses with specific subjects, teachers, and time slots
* **Examination Management**: Create and track examinations for courses
* **Grading System**: Record and manage student grades for examinations
* **Dashboards**: Specialized dashboards for students, teachers, and deans

## System Requirements

* Ruby 3.x
* Rails 8.0.1
* SQLite 2.1+ (development/testing)
* Node.js and Yarn for JavaScript dependencies

## Installation

1. Clone the repository
   ```bash
   git clone https://github.com/NoahDelgado/ror-school
   cd ror-school
   ```

2. Install dependencies
   ```bash
   bundle install
   ```

3. Set up the database
   ```bash
   rails db:create
   rails db:migrate
   rails db:seed
   ```
4. Check the terminal outpout for the users credential

5. Start the Rails server
   ```bash
   rails server
   ```

6. Visit http://localhost:3000 in your browser


## Database Structure

The application utilizes the following main models:

* **Person**: Base class for different user types (Student, Teacher, Dean, Administrator)
* **SchoolClass**: Represents a class with students and assigned teacher
* **Course**: Represents a subject taught by a teacher in a specific time slot
* **Examination**: Tests or assignments for courses
* **Grade**: Student grades for examinations
* **Moment**: Time periods (semesters, terms, etc.)
* **Subject**: Academic subjects taught in courses
* **Room**: Physical classrooms where classes take place
* **Section**: Departments or sections within the school

## License

This project is licensed under the MIT License - see the LICENSE file for details. 