# Logical Data Model Comparison

This document presents a comparison between the logical data models of the original DBDRZ schema and the current implementation.

## Original DBDRZ Schema (LDM)

```mermaid
erDiagram
    ADDRESSES {
        int id PK
        int zip
        varchar(150) town
        varchar(150) street
        varchar(4) number
    }
    
    MOMENTS {
        int id PK
        varchar(255) uid UK
        date start_on
        date end_on
        enum type "QUARTER, SEMESTER, YEAR"
    }
    
    ROOMS {
        int id PK
        varchar(8) name
    }
    
    SECTIONS {
        int id PK
        varchar(100) name
    }
    
    STATUSES {
        int id PK
        varchar(100) slug UK
        varchar(100) title
    }
    
    PEOPLE {
        int id PK
        varchar(255) username
        varchar(255) firstname
        varchar(255) lastname
        varchar(255) email
        varchar(12) phone_number
        enum type "STUDENT, TEACHER"
        varchar(34) iban
        int status_id FK
        int address_id FK
    }
    
    CLASSES {
        int id PK
        varchar(255) uid UK
        varchar(8) name
        int moment_id FK
        int section_id FK
        int room_id FK
        int master_id FK "teacher"
    }
    
    STUDENTS_FOLLOW_CLASSES {
        int student_id FK
        int class_id FK
    }
    
    SUBJECTS {
        int id PK
        varchar(100) slug UK
        varchar(100) name
    }
    
    COURSES {
        int id PK
        time start_at
        time end_at
        enum week_day "MON-SUN"
        int subject_id FK
        int teacher_id FK
        int class_id FK
        int moment_id FK
    }
    
    EXAMINATIONS {
        int id PK
        varchar(45) title
        date effective_date
        int course_id FK
    }
    
    GRADES {
        int id PK
        int value
        date executed_on
        int examination_id FK
        int student_id FK
    }
    
    ADDRESSES ||--o{ PEOPLE : "has"
    STATUSES ||--o{ PEOPLE : "has"
    PEOPLE ||--o{ CLASSES : "teaches"
    ROOMS ||--o{ CLASSES : "used by"
    MOMENTS ||--o{ CLASSES : "scheduled in"
    SECTIONS ||--o{ CLASSES : "belongs to"
    CLASSES ||--o{ STUDENTS_FOLLOW_CLASSES : "has"
    PEOPLE ||--o{ STUDENTS_FOLLOW_CLASSES : "enrolled in"
    SUBJECTS ||--o{ COURSES : "has"
    PEOPLE ||--o{ COURSES : "teaches"
    CLASSES ||--o{ COURSES : "has"
    MOMENTS ||--o{ COURSES : "scheduled in"
    COURSES ||--o{ EXAMINATIONS : "has"
    EXAMINATIONS ||--o{ GRADES : "has"
    PEOPLE ||--o{ GRADES : "receives"
```

## Current Implementation Schema (LDM)

```mermaid
    erDiagram
        ADDRESSES {
            int id PK
            varchar(255) zip
            varchar(255) town
            varchar(255) street
            varchar(255) number
            timestamp created_at
            timestamp updated_at
        }
        
        MOMENTS {
            int id PK
            varchar(255) uid
            datetime start_at
            datetime end_at
            varchar(255) period_type
            int year
            int period_number
            datetime deleted_at
            timestamp created_at
            timestamp updated_at
        }
        
        ROOMS {
            int id PK
            varchar(255) name
            timestamp created_at
            timestamp updated_at
        }
        
        SECTIONS {
            int id PK
            varchar(255) name
            timestamp created_at
            timestamp updated_at
        }
        
        STATUSES {
            int id PK
            varchar(255) slug
            varchar(255) title
            timestamp created_at
            timestamp updated_at
        }
        
        PEOPLE {
            int id PK
            varchar(255) email UK
            varchar(255) encrypted_password
            varchar(255) reset_password_token UK
            datetime reset_password_sent_at
            datetime remember_created_at
            varchar(255) username
            varchar(255) firstname
            varchar(255) lastname
            varchar(255) phone_number
            varchar(255) iban
            int address_id FK
            varchar(255) type
            int status_id FK
            datetime deleted_at
            timestamp created_at
            timestamp updated_at
        }
        
        SCHOOL_CLASSES {
            int id PK
            varchar(255) uid
            varchar(255) name
            int person_id FK "teacher"
            int room_id FK
            int moment_id FK
            int section_id FK
            datetime deleted_at
            timestamp created_at
            timestamp updated_at
        }
        
        STUDENTS_FOLLOW_CLASSES {
            int student_id FK
            int school_class_id FK
        }
        
        SUBJECTS {
            int id PK
            varchar(255) name
            timestamp created_at
            timestamp updated_at
        }
        
        COURSES {
            int id PK
            datetime start_at
            datetime end_at
            int week_day
            int subject_id FK
            int moment_id FK
            int person_id FK "teacher"
            int school_class_id FK
            datetime deleted_at
            timestamp created_at
            timestamp updated_at
        }
        
        EXAMINATIONS {
            int id PK
            varchar(255) title
            datetime expected_at
            int course_id FK
            datetime deleted_at
            timestamp created_at
            timestamp updated_at
        }
        
        GRADES {
            int id PK
            int value
            datetime expected_at
            int examination_id FK
            int person_id FK "student"
            datetime deleted_at
            timestamp created_at
            timestamp updated_at
        }
        
        ADDRESSES ||--o{ PEOPLE : "has"
        STATUSES ||--o{ PEOPLE : "has"
        PEOPLE ||--o{ SCHOOL_CLASSES : "teaches"
        ROOMS ||--o{ SCHOOL_CLASSES : "used by"
        MOMENTS ||--o{ SCHOOL_CLASSES : "scheduled in"
        SECTIONS ||--o{ SCHOOL_CLASSES : "belongs to"
        SCHOOL_CLASSES ||--o{ STUDENTS_FOLLOW_CLASSES : "has"
        PEOPLE ||--o{ STUDENTS_FOLLOW_CLASSES : "enrolled in"
        SUBJECTS ||--o{ COURSES : "has"
        PEOPLE ||--o{ COURSES : "teaches"
        SCHOOL_CLASSES ||--o{ COURSES : "has"
        MOMENTS ||--o{ COURSES : "scheduled in"
        COURSES ||--o{ EXAMINATIONS : "has"
        EXAMINATIONS ||--o{ GRADES : "has"
        PEOPLE ||--o{ GRADES : "receives"
```

## Key Structural Differences in the LDM

1. **Entity Renaming**:
   - `CLASSES` → `SCHOOL_CLASSES` to avoid keyword conflicts

2. **Attribute Type Changes**:
   - Date fields → DateTime for more precise timestamp tracking
   - ENUMs → VARCHAR for greater flexibility and portability
   - Numeric fields → VARCHAR where needed (e.g., zip codes)

3. **New Attributes**:
   - Soft delete tracking (`deleted_at`) in most entities
   - Audit timestamps (`created_at`, `updated_at`) in all entities
   - Authentication fields in PEOPLE entity

4. **Relationship Changes**:
   - Foreign keys renamed for consistency (e.g., `teacher_id` → `person_id`)
   - Some nullable foreign keys made mandatory
   - Removal of explicit ON DELETE/UPDATE behaviors

5. **Constraint Changes**:
   - Relaxed NOT NULL constraints on many fields
   - Unique constraint changes (single fields vs. composite)
   - Added unique constraint on student-class association
