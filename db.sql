create table sql1_es_test.addresses
(
    id     int auto_increment
        primary key,
    zip    int          not null,
    town   varchar(150) not null,
    street varchar(150) not null,
    number varchar(4)   not null
);

create table sql1_es_test.moments
(
    id       int auto_increment
        primary key,
    uid      varchar(255)                         not null,
    start_on date                                 not null,
    end_on   date                                 not null,
    type     enum ('QUARTER', 'SEMESTER', 'YEAR') not null,
    constraint moments_uid_uindex
        unique (uid)
);

create table sql1_es_test.rooms
(
    id   int auto_increment
        primary key,
    name varchar(8) not null
);

create table sql1_es_test.sections
(
    id   int auto_increment
        primary key,
    name varchar(100) not null
);

create table sql1_es_test.statuses
(
    id    int auto_increment
        primary key,
    slug  varchar(100) not null,
    title varchar(100) not null,
    constraint statuses_slug_uindex
        unique (slug)
);

create table sql1_es_test.people
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
    constraint people_uk
        unique (email, phone_number, username),
    constraint people_address_fk
        foreign key (address_id) references sql1_es_test.addresses (id),
    constraint people_status_fk
        foreign key (status_id) references sql1_es_test.statuses (id)
);

create table sql1_es_test.classes
(
    id         int auto_increment
        primary key,
    uid        varchar(255) not null,
    name       varchar(8)   not null,
    moment_id  int          not null,
    section_id int          not null,
    room_id    int          null,
    master_id  int          null,
    constraint classes_uid_uindex
        unique (uid),
    constraint class_moment_fk
        foreign key (moment_id) references sql1_es_test.moments (id),
    constraint class_room_fk
        foreign key (room_id) references sql1_es_test.rooms (id)
            on update set null,
    constraint class_section_fk
        foreign key (section_id) references sql1_es_test.sections (id),
    constraint classes_master_fk
        foreign key (master_id) references sql1_es_test.people (id)
);

create index class_master_fk
    on sql1_es_test.classes (master_id);

create table sql1_es_test.classes_students
(
    student_id int not null,
    class_id   int not null,
    constraint classes_class_fk
        foreign key (class_id) references sql1_es_test.classes (id)
            on delete cascade,
    constraint classes_student_fk
        foreign key (student_id) references sql1_es_test.people (id)
            on delete cascade
);

create index people_username_index
    on sql1_es_test.people (username);

create index statuses_slug_index
    on sql1_es_test.statuses (slug);

create table sql1_es_test.subjects
(
    id   int auto_increment
        primary key,
    slug varchar(100) not null,
    name varchar(100) not null,
    constraint subjects_pk2
        unique (slug)
);

create table sql1_es_test.courses
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
        foreign key (subject_id) references sql1_es_test.subjects (id)
            on update set null,
    constraint course_teacher_fk
        foreign key (teacher_id) references sql1_es_test.people (id)
            on delete set null,
    constraint courses_class_fk
        foreign key (class_id) references sql1_es_test.classes (id)
            on delete cascade,
    constraint courses_moment_fk
        foreign key (moment_id) references sql1_es_test.moments (id),
    constraint check_start_time_down_from_end
        check (`start_at` < `end_at`)
);

create table sql1_es_test.examinations
(
    id             int auto_increment
        primary key,
    title          varchar(45) not null,
    effective_date date        not null,
    course_id      int         not null,
    constraint examinations_course_fk
        foreign key (course_id) references sql1_es_test.courses (id)
            on delete cascade
);

create table sql1_es_test.grades
(
    id             int auto_increment
        primary key,
    value          int  not null comment 'Result of exam multiplied by 100 to avoid float values',
    executed_on    date not null,
    examination_id int  not null,
    student_id     int  not null,
    constraint grades_examination_fk
        foreign key (examination_id) references sql1_es_test.examinations (id),
    constraint grades_student_fk
        foreign key (student_id) references sql1_es_test.people (id)
);