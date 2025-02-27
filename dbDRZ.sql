CREATE DATABASE drz_sql1;
USE drz_sql1;

create table if not exists addresses
(
    id     int auto_increment
        primary key,
    zip    int          not null,
    town   varchar(150) not null,
    street varchar(150) not null,
    number varchar(4)   not null
);

create table if not exists moments
(
    id       int auto_increment
        primary key,
    uid      varchar(255)                         not null,
    start_on date                                 not null,
    end_on   date                                 not null,
    type     enum ('QUARTER', 'SEMESTER', 'YEAR') not null,
    constraint moments_uid_uk
        unique (uid)
);

create table if not exists rooms
(
    id   int auto_increment
        primary key,
    name varchar(8) not null
);

create table if not exists sections
(
    id   int auto_increment
        primary key,
    name varchar(100) not null
);

create table if not exists statuses
(
    id    int auto_increment
        primary key,
    slug  varchar(100) not null,
    title varchar(100) not null,
    constraint status_slug_uk
        unique (slug)
);

create table if not exists people
(
    id           int auto_increment
        primary key,
    username     varchar(255)                                  not null,
    firstname    varchar(255)                                  not null,
    lastname     varchar(255)                                  not null,
    email        varchar(255)                                  not null,
    phone_number varchar(12)                                   not null,
    type         enum ('STUDENT', 'TEACHER') default 'STUDENT' not null,
    iban         varchar(34)                                   null,
    status_id    int                                           not null,
    address_id   int                                           null,
    constraint person_uk
        unique (email, phone_number, username),
    constraint person_address_fk
        foreign key (address_id) references addresses (id),
    constraint person_status_fk
        foreign key (status_id) references statuses (id)
);

create table if not exists classes
(
    id         int auto_increment
        primary key,
    uid        varchar(255) not null,
    name       varchar(8)   not null,
    moment_id  int          not null,
    section_id int          not null,
    room_id    int          null,
    master_id  int          null,
    constraint class_uid_uk
        unique (uid),
    constraint class_moment_fk
        foreign key (moment_id) references moments (id),
    constraint class_room_fk
        foreign key (room_id) references rooms (id)
            on update set null,
    constraint class_section_fk
        foreign key (section_id) references sections (id),
    constraint class_master_fk
        foreign key (master_id) references people (id)
);

create index class_master_fk
    on classes (master_id);

create table if not exists students_follow_classes
(
    student_id int not null,
    class_id   int not null,
    constraint class_student_fk
        foreign key (class_id) references classes (id)
            on delete cascade,
    constraint student_class_fk
        foreign key (student_id) references people (id)
            on delete cascade
);

create index person_username_index
    on people (username);

create index status_slug_index
    on statuses (slug);

create table if not exists subjects
(
    id   int auto_increment
        primary key,
    slug varchar(100) not null,
    name varchar(100) not null,
    constraint subject_uk
        unique (slug)
);

create table if not exists courses
(
    id         int auto_increment
        primary key,
    start_at   time                                                                                null,
    end_at     time                                                                                null,
    week_day   enum ('MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY') not null,
    subject_id int                                                                                 null,
    teacher_id int                                                                                 null,
    class_id   int                                                                                 not null,
    moment_id  int                                                                                 not null,
    constraint course_subject_fk
        foreign key (subject_id) references subjects (id)
            on update set null,
    constraint course_teacher_fk
        foreign key (teacher_id) references people (id)
            on delete set null,
    constraint course_class_fk
        foreign key (class_id) references classes (id)
            on delete cascade,
    constraint course_moment_fk
        foreign key (moment_id) references moments (id),
    constraint check_start_time_down_from_end
        check (`start_at` < `end_at`)
);

create table if not exists examinations
(
    id             int auto_increment
        primary key,
    title          varchar(45) not null,
    effective_date date        not null,
    course_id      int         not null,
    constraint examination_course_fk
        foreign key (course_id) references courses (id)
            on delete cascade
);

create table if not exists grades
(
    id             int auto_increment
        primary key,
    value          int  not null comment 'Result of exam multiplied by 100 to avoid float values',
    executed_on    date not null,
    examination_id int  not null,
    student_id     int  not null,
    constraint grade_examination_fk
        foreign key (examination_id) references examinations (id),
    constraint grade_student_fk
        foreign key (student_id) references people (id)
);
