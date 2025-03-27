# Database Schema Comparison: DBDRZ vs Current Implementation

## Table Structure Comparison

| Original (DBDRZ.sql) | Current Implementation | Difference |
|---------------------|---------------------|--------|
| addresses | addresses | Field types & constraints modified |
| moments | moments | Field types & naming modified, index added |
| rooms | rooms | Unchanged |
| sections | sections | Unchanged |
| statuses | statuses | Unchanged |
| people | people | Authentication fields added |
| classes | school_classes | Renamed & relation structure modified |
| students_follow_classes | students_follow_classes | Relation references modified |
| subjects | subjects | Unchanged |
| courses | courses | Field types & constraints modified |
| examinations | examinations | Field naming & types modified |
| grades | grades | Field naming modified |

## Detailed Attribute Comparison

### addresses

**Original:**
```sql
CREATE TABLE addresses (
    id     int auto_increment primary key,
    zip    int          not null,
    town   varchar(150) not null,
    street varchar(150) not null,
    number varchar(4)   not null
);
```

**Current:**
```sql
CREATE TABLE addresses (
    id     int auto_increment primary key,
    zip    varchar(255),
    town   varchar(255),
    street varchar(255),
    number varchar(255),
    created_at timestamp not null,
    updated_at timestamp not null
);
```

**Key Differences:**
- ZIP changed from integer to varchar to support alphanumeric postal codes
- NOT NULL constraints removed from address fields
- Standard timestamp fields added

### moments

**Original:**
```sql
CREATE TABLE moments (
    id       int auto_increment primary key,
    uid      varchar(255)                         not null,
    start_on date                                 not null,
    end_on   date                                 not null,
    type     enum ('QUARTER', 'SEMESTER', 'YEAR') not null,
    constraint moments_uid_uk unique (uid)
);
```

**Current:**
```sql
CREATE TABLE moments (
    id            int auto_increment primary key,
    uid           varchar(255),
    start_at      datetime,
    end_at        datetime,
    period_type   varchar(255),
    year          int,
    period_number int,
    deleted_at    datetime,
    created_at    timestamp not null,
    updated_at    timestamp not null,
    index index_moments_on_deleted_at (deleted_at),
    constraint uniq_period_year_number unique (period_type, year, period_number)
);
```

**Key Differences:**
- Field naming: start_on/end_on → start_at/end_at
- Field types: date → datetime for more precision
- Field type: enum → varchar for type field
- Added explicit year and period_number columns
- Added soft delete column
- Changed uniqueness constraint from uid to composite (period_type, year, period_number)

### people

**Original:**
```sql
CREATE TABLE people (
    id           int auto_increment primary key,
    username     varchar(255)                          not null,
    firstname    varchar(255)                          not null,
    lastname     varchar(255)                          not null,
    email        varchar(255)                          not null,
    phone_number varchar(12)                           not null,
    type         enum ('STUDENT', 'TEACHER') default 'STUDENT' not null,
    iban         varchar(34)                           null,
    status_id    int                                   not null,
    address_id   int                                   null,
    constraint person_uk unique (email, phone_number, username),
    constraint person_address_fk foreign key (address_id) references addresses (id),
    constraint person_status_fk foreign key (status_id) references statuses (id)
);
```

**Current:**
```sql
CREATE TABLE people (
    id                   int auto_increment primary key,
    email                varchar(255) not null default '',
    encrypted_password   varchar(255) not null default '',
    reset_password_token varchar(255),
    reset_password_sent_at datetime,
    remember_created_at  datetime,
    username             varchar(255),
    firstname            varchar(255),
    lastname             varchar(255),
    phone_number         varchar(255),
    iban                 varchar(255),
    address_id           int,
    type                 varchar(255),
    status_id            int not null,
    deleted_at           datetime,
    created_at           timestamp not null,
    updated_at           timestamp not null,
    index index_people_on_address_id (address_id),
    index index_people_on_deleted_at (deleted_at),
    index index_people_on_email (email) unique,
    index index_people_on_reset_password_token (reset_password_token) unique,
    index index_people_on_status_id (status_id),
    constraint fk_rails_people_status foreign key (status_id) references statuses (id),
    constraint fk_rails_people_address foreign key (address_id) references addresses (id)
);
```

**Key Differences:**
- Added authentication fields (encrypted_password, reset tokens)
- Changed type field from enum to varchar
- Removed NOT NULL constraints from most fields
- Changed uniqueness constraint from composite (email, phone, username) to just email
- Added indexes for better query performance
- Added soft delete column

### classes vs. school_classes

**Original:**
```sql
CREATE TABLE classes (
    id         int auto_increment primary key,
    uid        varchar(255) not null,
    name       varchar(8)   not null,
    moment_id  int          not null,
    section_id int          not null,
    room_id    int          null,
    master_id  int          null,
    constraint class_uid_uk unique (uid),
    constraint class_moment_fk foreign key (moment_id) references moments (id),
    constraint class_room_fk foreign key (room_id) references rooms (id) on update set null,
    constraint class_section_fk foreign key (section_id) references sections (id),
    constraint class_master_fk foreign key (master_id) references people (id)
);
```

**Current:**
```sql
CREATE TABLE school_classes (
    id         int auto_increment primary key,
    uid        varchar(255),
    name       varchar(255),
    person_id  int not null,
    room_id    int not null,
    moment_id  int not null,
    section_id int not null,
    deleted_at datetime,
    created_at timestamp not null,
    updated_at timestamp not null,
    index index_school_classes_on_deleted_at (deleted_at),
    index index_school_classes_on_moment_id (moment_id),
    index index_school_classes_on_person_id (person_id),
    index index_school_classes_on_room_id (room_id),
    index index_school_classes_on_section_id (section_id),
    constraint fk_rails_school_classes_moment foreign key (moment_id) references moments (id),
    constraint fk_rails_school_classes_person foreign key (person_id) references people (id),
    constraint fk_rails_school_classes_room foreign key (room_id) references rooms (id),
    constraint fk_rails_school_classes_section foreign key (section_id) references sections (id)
);
```

**Key Differences:**
- Table renamed from classes to school_classes
- Renamed master_id to person_id
- Changed room_id from nullable to required (NOT NULL)
- Removed unique constraint on uid
- Removed optional update behavior on room_id foreign key
- Added indexes for all foreign keys
- Added soft delete column

### students_follow_classes

**Original:**
```sql
CREATE TABLE students_follow_classes (
    student_id int not null,
    class_id   int not null,
    constraint class_student_fk foreign key (class_id) references classes (id) on delete cascade,
    constraint student_class_fk foreign key (student_id) references people (id) on delete cascade
);
```

**Current:**
```sql
CREATE TABLE students_follow_classes (
    student_id      int not null,
    school_class_id int not null,
    index index_students_follow_classes_on_school_class_id (school_class_id),
    index index_students_follow_classes_on_student_id (student_id),
    index idx_on_student_id_school_class_id_eecdf1d700 (student_id, school_class_id) unique,
    constraint fk_rails_students_follow_classes_school_class foreign key (school_class_id) references school_classes (id),
    constraint fk_rails_students_follow_classes_student foreign key (student_id) references people (id)
);
```

**Key Differences:**
- Renamed class_id to school_class_id to match renamed table
- Added indexes for improved query performance
- Added unique constraint on (student_id, school_class_id) to prevent duplicates
- Cascade delete behavior is no longer explicit in SQL

### courses

**Original:**
```sql
CREATE TABLE courses (
    id         int auto_increment primary key,
    start_at   time                                                                                null,
    end_at     time                                                                                null,
    week_day   enum ('MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY') not null,
    subject_id int                                                                                 null,
    teacher_id int                                                                                 null,
    class_id   int                                                                                 not null,
    moment_id  int                                                                                 not null,
    constraint course_subject_fk foreign key (subject_id) references subjects (id) on update set null,
    constraint course_teacher_fk foreign key (teacher_id) references people (id) on delete set null,
    constraint course_class_fk foreign key (class_id) references classes (id) on delete cascade,
    constraint course_moment_fk foreign key (moment_id) references moments (id),
    constraint check_start_time_down_from_end check (`start_at` < `end_at`)
);
```

**Current:**
```sql
CREATE TABLE courses (
    id              int auto_increment primary key,
    start_at        datetime,
    end_at          datetime,
    week_day        int,
    subject_id      int not null,
    moment_id       int not null,
    person_id       int not null,
    school_class_id int not null,
    deleted_at      datetime,
    created_at      timestamp not null,
    updated_at      timestamp not null,
    index index_courses_on_deleted_at (deleted_at),
    index index_courses_on_moment_id (moment_id),
    index index_courses_on_person_id (person_id),
    index index_courses_on_school_class_id (school_class_id),
    index index_courses_on_subject_id (subject_id),
    constraint fk_rails_courses_moment foreign key (moment_id) references moments (id),
    constraint fk_rails_courses_person foreign key (person_id) references people (id),
    constraint fk_rails_courses_school_class foreign key (school_class_id) references school_classes (id),
    constraint fk_rails_courses_subject foreign key (subject_id) references subjects (id)
);
```

**Key Differences:**
- Changed time fields to datetime
- Changed week_day from enum to integer
- Renamed teacher_id to person_id
- Renamed class_id to school_class_id
- Changed nullable foreign keys to required (NOT NULL)
- Removed ON UPDATE/ON DELETE behaviors
- Removed CHECK constraint for time validation
- Added soft delete column
- Added indexes for all foreign keys

### examinations

**Original:**
```sql
CREATE TABLE examinations (
    id             int auto_increment primary key,
    title          varchar(45) not null,
    effective_date date        not null,
    course_id      int         not null,
    constraint examination_course_fk foreign key (course_id) references courses (id) on delete cascade
);
```

**Current:**
```sql
CREATE TABLE examinations (
    id          int auto_increment primary key,
    title       varchar(255),
    expected_at datetime,
    course_id   int not null,
    deleted_at  datetime,
    created_at  timestamp not null,
    updated_at  timestamp not null,
    index index_examinations_on_course_id (course_id),
    index index_examinations_on_deleted_at (deleted_at),
    constraint fk_rails_examinations_course foreign key (course_id) references courses (id)
);
```

**Key Differences:**
- Renamed effective_date to expected_at
- Changed date field to datetime
- Removed NOT NULL constraints
- Added soft delete column
- Added indexes
- Removed ON DELETE CASCADE behavior

### grades

**Original:**
```sql
CREATE TABLE grades (
    id             int auto_increment primary key,
    value          int  not null comment 'Result of exam multiplied by 100 to avoid float values',
    executed_on    date not null,
    examination_id int  not null,
    student_id     int  not null,
    constraint grade_examination_fk foreign key (examination_id) references examinations (id),
    constraint grade_student_fk foreign key (student_id) references people (id)
);
```

**Current:**
```sql
CREATE TABLE grades (
    id             int auto_increment primary key,
    value          int,
    expected_at    datetime,
    examination_id int not null,
    person_id      int not null,
    deleted_at     datetime,
    created_at     timestamp not null,
    updated_at     timestamp not null,
    index index_grades_on_deleted_at (deleted_at),
    index index_grades_on_examination_id (examination_id),
    index index_grades_on_person_id (person_id),
    constraint fk_rails_grades_examination foreign key (examination_id) references examinations (id),
    constraint fk_rails_grades_person foreign key (person_id) references people (id)
);
```

**Key Differences:**
- Renamed executed_on to expected_at
- Changed date field to datetime
- Renamed student_id to person_id
- Removed NOT NULL constraints from value
- Added soft delete column
- Added indexes for foreign keys

## Summary of Key SQL-Level Differences

1. **Data Type Changes**
   - Date fields → DateTime for more precision
   - ENUMs → VARCHAR for more flexibility and database portability
   - INT → VARCHAR for fields that may contain non-numeric characters

2. **Constraint Changes**
   - Removal of many NOT NULL constraints for flexibility
   - Changed uniqueness constraints
   - Composite PK on students_follow_classes added

3. **Foreign Key Behavior**
   - Removed ON DELETE CASCADE from many relationships
   - Simplified referential integrity approach

4. **Indexing**
   - Added proper indexes on all foreign keys
   - Added indexes for soft delete columns

5. **Table Structure**
   - Renamed classes → school_classes
   - Added soft delete columns
   - Added tracking columns (created_at, updated_at)

6. **Field Naming**
   - More consistent naming conventions (e.g., start_at/end_at instead of start_on/end_on)
   - Field renaming for clarity (teacher_id → person_id) 