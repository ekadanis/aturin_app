-- CORRECTED DATABASE SCHEMAS FOR ATURIN APP
-- Based on Dart models analysis

-- =============================================
-- ALARMS TABLE - CORRECTED
-- =============================================
CREATE TABLE alarms (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    alarm_date_time DATETIME NOT NULL,
    alarm_enabled BOOLEAN NOT NULL DEFAULT FALSE,
    slug VARCHAR(255) UNIQUE NOT NULL,
    created_at TIMESTAMP NULL DEFAULT NULL,
    updated_at TIMESTAMP NULL DEFAULT NULL
);

-- =============================================
-- USERS TABLE - CORRECTED  
-- =============================================
CREATE TABLE users (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NULL,
    avatar VARCHAR(255) NOT NULL DEFAULT '/assets/avatars/profile1.jpg',
    slug VARCHAR(255) UNIQUE NOT NULL,
    created_at TIMESTAMP NULL DEFAULT NULL,
    updated_at TIMESTAMP NULL DEFAULT NULL
);

-- =============================================
-- TASKS TABLE - CORRECTED
-- =============================================
CREATE TABLE tasks (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    title VARCHAR(255) NOT NULL DEFAULT 'Tak Berjudul',
    description TEXT NULL,
    deadline DATETIME NOT NULL DEFAULT (NOW() + INTERVAL 1 DAY),
    estimated_duration INTEGER NOT NULL DEFAULT 0, -- in minutes
    task_status ENUM('belum_selesai', 'selesai', 'terlambat') NOT NULL DEFAULT 'belum_selesai',
    completed_at DATETIME NULL,
    category ENUM('akademik', 'hiburan', 'pekerjaan', 'olahraga', 'sosial', 'spiritual', 'pribadi', 'istirahat') NOT NULL DEFAULT 'akademik',
    is_alarm_enabled BOOLEAN NOT NULL DEFAULT FALSE,
    alarm_date_time DATETIME NULL,
    is_done BOOLEAN NOT NULL DEFAULT FALSE,
    is_completed BOOLEAN NOT NULL DEFAULT FALSE,
    previous_status ENUM('completed', 'late', 'today', 'tomorrow', 'upcoming') NULL,
    alarm_id BIGINT NULL,
    slug VARCHAR(255) UNIQUE NULL,
    created_at TIMESTAMP NULL DEFAULT NULL,
    updated_at TIMESTAMP NULL DEFAULT NULL,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (alarm_id) REFERENCES alarms(id) ON DELETE CASCADE
);

-- =============================================
-- ACTIVITIES TABLE - CORRECTED
-- =============================================
CREATE TABLE activities (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    activity_title VARCHAR(255) NOT NULL,
    activity_date DATE NOT NULL,
    activity_start_time DATETIME NOT NULL,
    activity_complete_time DATETIME NOT NULL,
    activity_category ENUM('akademik', 'hiburan', 'pekerjaan', 'olahraga', 'sosial', 'spiritual', 'pribadi', 'istirahat') NOT NULL,
    alarm_id BIGINT NULL,
    slug VARCHAR(255) UNIQUE NULL,
    created_at TIMESTAMP NULL DEFAULT NULL,
    updated_at TIMESTAMP NULL DEFAULT NULL,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (alarm_id) REFERENCES alarms(id) ON DELETE CASCADE
);

-- =============================================
-- MAIN ISSUES FIXED:
-- =============================================

-- 1. ALARMS TABLE:
--    - Added missing 'slug' field (present in schema but missing in model alignment)
--    - Fixed field naming consistency (alarm_date_time vs alarm_date_time)
--    - Changed is_alarm_enabled to alarm_enabled to match AlarmModel
--    - Added proper timestamps

-- 2. USERS TABLE:
--    - Schema was mostly correct, just ensured consistency
--    - Made password nullable (as in User model)
--    - Proper avatar default value

-- 3. TASKS TABLE:
--    - Changed task_title to title (to match Task model)
--    - Changed task_description to description
--    - Changed task_deadline to deadline
--    - Changed estimated_task_duration to estimated_duration (INTEGER for minutes)
--    - Removed task_ prefix from most fields to match Dart model
--    - Added missing fields: is_done, is_completed, previous_status
--    - Fixed alarm relationship fields
--    - Added slug field as nullable
--    - Made title length more flexible (255 instead of 20)

-- 4. ACTIVITIES TABLE:
--    - Fixed typo: 'olaharaga' -> 'olahraga'
--    - Changed time fields to DATETIME instead of TIME to store full timestamp
--    - Made activity_title length more flexible (255 instead of 20)
--    - Added missing created_at and updated_at timestamps
--    - Added slug field as nullable

-- =============================================
-- ADDITIONAL NOTES:
-- =============================================
-- - All foreign key relationships are properly defined with CASCADE deletes
-- - ENUM values match exactly with Dart model enums
-- - Field names match Dart model property names after snake_case conversion
-- - Nullable fields in Dart models are properly nullable in SQL
-- - Default values match between Dart models and SQL schemas
