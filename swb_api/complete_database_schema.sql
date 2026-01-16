-- Complete Database Schema for SWB Party Needs Integrated Management System
-- Run this in your MySQL database (swb database)

-- ============================================
-- 1. USERS TABLE (already exists, but adding role if missing)
-- ============================================
ALTER TABLE `users` 
ADD COLUMN IF NOT EXISTS `role` VARCHAR(20) DEFAULT 'customer' AFTER `password`,
ADD COLUMN IF NOT EXISTS `api_token` VARCHAR(64) DEFAULT NULL AFTER `role`,
ADD COLUMN IF NOT EXISTS `phone` VARCHAR(20) DEFAULT NULL AFTER `email`,
ADD COLUMN IF NOT EXISTS `address` TEXT DEFAULT NULL AFTER `phone`;

-- ============================================
-- 2. EXPANDED RESERVATIONS TABLE
-- ============================================
DROP TABLE IF EXISTS `reservations`;
CREATE TABLE `reservations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `package_id` varchar(50) NOT NULL,
  `package_name` varchar(255) NOT NULL,
  -- Client Information
  `client_name` varchar(255) NOT NULL,
  `client_phone` varchar(20) DEFAULT NULL,
  `client_email` varchar(255) DEFAULT NULL,
  `client_address` text DEFAULT NULL,
  `venue_location` text DEFAULT NULL,
  `preferred_contact` varchar(20) DEFAULT 'phone',
  -- Event Details
  `event_type` varchar(50) DEFAULT NULL,
  `event_date` date NOT NULL,
  `event_start_time` time DEFAULT NULL,
  `event_end_time` time DEFAULT NULL,
  `number_of_guests` int(11) NOT NULL,
  `event_theme` varchar(255) DEFAULT NULL,
  `venue_type` varchar(50) DEFAULT NULL,
  -- Services Required
  `needs_decoration` tinyint(1) DEFAULT 0,
  `needs_equipment` tinyint(1) DEFAULT 0,
  `needs_entertainment` tinyint(1) DEFAULT 0,
  `needs_photography` tinyint(1) DEFAULT 0,
  `needs_cleanup` tinyint(1) DEFAULT 0,
  `services_notes` text DEFAULT NULL,
  -- Budget & Payment
  `estimated_budget` decimal(10,2) DEFAULT NULL,
  `deposit_amount` decimal(10,2) DEFAULT 0.00,
  `total_amount` decimal(10,2) DEFAULT NULL,
  `payment_method` varchar(50) DEFAULT NULL,
  `payment_status` varchar(20) DEFAULT 'Pending',
  `payment_schedule` varchar(50) DEFAULT NULL,
  -- Additional Notes
  `special_requests` text DEFAULT NULL,
  `accessibility_requirements` text DEFAULT NULL,
  `contact_person` varchar(255) DEFAULT NULL,
  -- System Fields
  `status` varchar(20) DEFAULT 'Pending',
  `approved_by` int(11) DEFAULT NULL,
  `approved_at` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `event_date` (`event_date`),
  KEY `status` (`status`),
  KEY `payment_status` (`payment_status`),
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`approved_by`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================
-- 3. INVENTORY TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS `inventory` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `item_name` varchar(255) NOT NULL,
  `category` varchar(100) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `quantity_available` int(11) DEFAULT 0,
  `quantity_reserved` int(11) DEFAULT 0,
  `unit_price` decimal(10,2) DEFAULT 0.00,
  `reorder_level` int(11) DEFAULT 10,
  `supplier` varchar(255) DEFAULT NULL,
  `last_restocked` date DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `category` (`category`),
  KEY `item_name` (`item_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================
-- 4. RESERVATION_INVENTORY (Many-to-Many)
-- ============================================
CREATE TABLE IF NOT EXISTS `reservation_inventory` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `reservation_id` int(11) NOT NULL,
  `inventory_id` int(11) NOT NULL,
  `quantity_needed` int(11) NOT NULL,
  `quantity_returned` int(11) DEFAULT 0,
  `status` varchar(20) DEFAULT 'Reserved',
  `notes` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `reservation_id` (`reservation_id`),
  KEY `inventory_id` (`inventory_id`),
  FOREIGN KEY (`reservation_id`) REFERENCES `reservations`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`inventory_id`) REFERENCES `inventory`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================
-- 5. EMPLOYEE_TASKS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS `employee_tasks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `reservation_id` int(11) NOT NULL,
  `assigned_to` int(11) NOT NULL,
  `task_type` varchar(50) NOT NULL,
  `task_description` text NOT NULL,
  `scheduled_date` date NOT NULL,
  `scheduled_time` time DEFAULT NULL,
  `status` varchar(20) DEFAULT 'Pending',
  `priority` varchar(20) DEFAULT 'Medium',
  `completed_at` datetime DEFAULT NULL,
  `completion_notes` text DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `reservation_id` (`reservation_id`),
  KEY `assigned_to` (`assigned_to`),
  KEY `scheduled_date` (`scheduled_date`),
  KEY `status` (`status`),
  FOREIGN KEY (`reservation_id`) REFERENCES `reservations`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`assigned_to`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`created_by`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================
-- 6. PAYMENTS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS `payments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `reservation_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `payment_type` varchar(50) NOT NULL,
  `payment_method` varchar(50) NOT NULL,
  `transaction_reference` varchar(255) DEFAULT NULL,
  `payment_date` datetime NOT NULL,
  `status` varchar(20) DEFAULT 'Completed',
  `notes` text DEFAULT NULL,
  `recorded_by` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `reservation_id` (`reservation_id`),
  KEY `user_id` (`user_id`),
  KEY `payment_date` (`payment_date`),
  FOREIGN KEY (`reservation_id`) REFERENCES `reservations`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`recorded_by`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================
-- 7. EXPENSES TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS `expenses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `category` varchar(100) NOT NULL,
  `description` text NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `expense_date` date NOT NULL,
  `vendor` varchar(255) DEFAULT NULL,
  `invoice_number` varchar(100) DEFAULT NULL,
  `reservation_id` int(11) DEFAULT NULL,
  `approved_by` int(11) DEFAULT NULL,
  `approved_at` datetime DEFAULT NULL,
  `status` varchar(20) DEFAULT 'Pending',
  `created_by` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `expense_date` (`expense_date`),
  KEY `category` (`category`),
  KEY `reservation_id` (`reservation_id`),
  KEY `status` (`status`),
  FOREIGN KEY (`reservation_id`) REFERENCES `reservations`(`id`) ON DELETE SET NULL,
  FOREIGN KEY (`approved_by`) REFERENCES `users`(`id`) ON DELETE SET NULL,
  FOREIGN KEY (`created_by`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================
-- 8. EVENT_REPORTS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS `event_reports` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `reservation_id` int(11) NOT NULL,
  `reported_by` int(11) NOT NULL,
  `event_rating` int(11) DEFAULT NULL,
  `customer_feedback` text DEFAULT NULL,
  `issues_encountered` text DEFAULT NULL,
  `items_damaged` text DEFAULT NULL,
  `items_missing` text DEFAULT NULL,
  `recommendations` text DEFAULT NULL,
  `reported_at` datetime NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `reservation_id` (`reservation_id`),
  FOREIGN KEY (`reservation_id`) REFERENCES `reservations`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`reported_by`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================
-- 9. NOTIFICATIONS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS `notifications` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `type` varchar(50) NOT NULL,
  `title` varchar(255) NOT NULL,
  `message` text NOT NULL,
  `related_id` int(11) DEFAULT NULL,
  `related_type` varchar(50) DEFAULT NULL,
  `is_read` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `is_read` (`is_read`),
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
