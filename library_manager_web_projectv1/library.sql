-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3306
-- Generation Time: Jul 10, 2025 at 07:57 AM
-- Server version: 10.11.10-MariaDB-log
-- PHP Version: 7.2.34

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `PLACE_YOUR_DB_NAME`
--

-- --------------------------------------------------------

--
-- Table structure for table `payments`
--

CREATE TABLE `payments` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `seat_id` int(11) NOT NULL,
  `session_id` int(11) NOT NULL,
  `seat_number` varchar(10) NOT NULL,
  `date_of_joining` date NOT NULL,
  `date_of_leaving` date NOT NULL,
  `duration_days` int(11) NOT NULL,
  `amount_due` decimal(10,2) NOT NULL,
  `generated_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `payments`
--

INSERT INTO `payments` (`id`, `user_id`, `seat_id`, `session_id`, `seat_number`, `date_of_joining`, `date_of_leaving`, `duration_days`, `amount_due`, `generated_at`) VALUES
(1, 2, 104, 1, 'A3', '2025-07-10', '2025-07-10', 1, 500.00, '2025-07-10 03:37:52'),
(2, 2, 109, 1, 'B3', '2025-07-10', '2025-07-10', 1, 500.00, '2025-07-10 03:38:38'),
(3, 2, 103, 1, 'A2', '2025-07-10', '2025-07-10', 1, 500.00, '2025-07-10 03:38:40');

-- --------------------------------------------------------

--
-- Table structure for table `seats`
--

CREATE TABLE `seats` (
  `id` int(11) NOT NULL,
  `seat_number` varchar(10) NOT NULL,
  `status` enum('available','requested','booked','cancelled') NOT NULL DEFAULT 'available',
  `user_id` int(11) DEFAULT NULL,
  `session_id` int(11) NOT NULL,
  `date_of_joining` date DEFAULT NULL,
  `date_of_leaving` date DEFAULT NULL,
  `requested_by_id` int(11) DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `seats`
--

INSERT INTO `seats` (`id`, `seat_number`, `status`, `user_id`, `session_id`, `date_of_joining`, `date_of_leaving`, `requested_by_id`, `updated_at`) VALUES
(102, 'A1', '', NULL, 1, NULL, NULL, NULL, '2025-07-10 03:23:42'),
(103, 'A2', 'booked', 3, 1, '0000-00-00', NULL, NULL, '2025-07-10 03:58:17'),
(104, 'A3', 'available', NULL, 1, NULL, NULL, NULL, '2025-07-10 03:37:52'),
(105, 'A4', 'available', NULL, 1, NULL, NULL, NULL, '2025-07-10 02:54:02'),
(106, 'A5', 'available', NULL, 1, NULL, NULL, NULL, '2025-07-10 02:54:02'),
(107, 'B1', 'booked', 3, 1, '2025-07-10', NULL, NULL, '2025-07-10 06:34:59'),
(108, 'B2', 'available', NULL, 1, NULL, NULL, NULL, '2025-07-10 02:54:02'),
(109, 'B3', 'available', NULL, 1, NULL, NULL, NULL, '2025-07-10 03:38:38'),
(110, 'B4', 'booked', 4, 1, '0000-00-00', NULL, NULL, '2025-07-10 03:58:23'),
(111, 'B5', 'available', NULL, 1, NULL, NULL, NULL, '2025-07-10 03:36:25'),
(112, 'C1', 'available', NULL, 1, NULL, NULL, NULL, '2025-07-10 02:54:02'),
(113, 'C2', 'available', NULL, 1, NULL, NULL, NULL, '2025-07-10 02:54:02'),
(114, 'C3', 'requested', NULL, 1, NULL, NULL, 2, '2025-07-10 06:40:49'),
(115, 'C4', 'available', NULL, 1, NULL, NULL, NULL, '2025-07-10 02:54:02'),
(116, 'C5', 'available', NULL, 1, NULL, NULL, NULL, '2025-07-10 02:54:02'),
(117, 'D1', 'available', NULL, 1, NULL, NULL, NULL, '2025-07-10 02:54:02'),
(118, 'D2', 'available', NULL, 1, NULL, NULL, NULL, '2025-07-10 02:54:02'),
(119, 'D3', 'available', NULL, 1, NULL, NULL, NULL, '2025-07-10 02:54:02'),
(120, 'D4', 'available', NULL, 1, NULL, NULL, NULL, '2025-07-10 02:54:02'),
(121, 'D5', 'available', NULL, 1, NULL, NULL, NULL, '2025-07-10 02:54:02'),
(122, 'E1', 'available', NULL, 1, NULL, NULL, NULL, '2025-07-10 02:54:02'),
(123, 'E2', 'available', NULL, 1, NULL, NULL, NULL, '2025-07-10 02:54:02'),
(124, 'E3', 'available', NULL, 1, NULL, NULL, NULL, '2025-07-10 02:54:02'),
(125, 'E4', 'available', NULL, 1, NULL, NULL, NULL, '2025-07-10 02:54:02'),
(126, 'E5', 'available', NULL, 1, NULL, NULL, NULL, '2025-07-10 02:54:02'),
(127, 'A1', 'available', NULL, 2, NULL, NULL, NULL, '2025-07-10 03:31:41'),
(128, 'A2', 'available', NULL, 2, NULL, NULL, NULL, '2025-07-10 03:31:41'),
(129, 'A3', 'available', NULL, 2, NULL, NULL, NULL, '2025-07-10 03:31:41'),
(130, 'A4', 'available', NULL, 2, NULL, NULL, NULL, '2025-07-10 03:31:41'),
(131, 'A5', 'available', NULL, 2, NULL, NULL, NULL, '2025-07-10 03:31:41'),
(132, 'A6', 'available', NULL, 2, NULL, NULL, NULL, '2025-07-10 03:31:41'),
(133, 'A7', 'available', NULL, 2, NULL, NULL, NULL, '2025-07-10 03:31:41'),
(134, 'A8', 'available', NULL, 2, NULL, NULL, NULL, '2025-07-10 03:31:41'),
(135, 'A9', 'available', NULL, 2, NULL, NULL, NULL, '2025-07-10 03:31:41'),
(136, 'A10', 'available', NULL, 2, NULL, NULL, NULL, '2025-07-10 03:31:41'),
(137, 'B1', 'available', NULL, 2, NULL, NULL, NULL, '2025-07-10 03:31:41'),
(138, 'B2', 'available', NULL, 2, NULL, NULL, NULL, '2025-07-10 03:31:41'),
(139, 'B3', 'available', NULL, 2, NULL, NULL, NULL, '2025-07-10 03:31:41'),
(140, 'B4', 'available', NULL, 2, NULL, NULL, NULL, '2025-07-10 03:31:41'),
(141, 'B5', 'available', NULL, 2, NULL, NULL, NULL, '2025-07-10 03:31:41'),
(142, 'B6', 'available', NULL, 2, NULL, NULL, NULL, '2025-07-10 03:31:41'),
(143, 'B7', 'available', NULL, 2, NULL, NULL, NULL, '2025-07-10 03:31:41'),
(144, 'B8', 'available', NULL, 2, NULL, NULL, NULL, '2025-07-10 03:31:41'),
(145, 'B9', 'available', NULL, 2, NULL, NULL, NULL, '2025-07-10 03:31:41'),
(146, 'B10', 'available', NULL, 2, NULL, NULL, NULL, '2025-07-10 03:31:41'),
(147, 'C1', 'available', NULL, 2, NULL, NULL, NULL, '2025-07-10 03:31:41'),
(148, 'C2', 'available', NULL, 2, NULL, NULL, NULL, '2025-07-10 03:31:41'),
(149, 'C3', 'available', NULL, 2, NULL, NULL, NULL, '2025-07-10 03:31:41'),
(150, 'C4', 'available', NULL, 2, NULL, NULL, NULL, '2025-07-10 03:31:41'),
(151, 'C5', 'available', NULL, 2, NULL, NULL, NULL, '2025-07-10 03:31:41'),
(152, 'C6', 'available', NULL, 2, NULL, NULL, NULL, '2025-07-10 03:31:41'),
(153, 'C7', 'available', NULL, 2, NULL, NULL, NULL, '2025-07-10 03:31:41'),
(154, 'C8', 'available', NULL, 2, NULL, NULL, NULL, '2025-07-10 03:31:41'),
(155, 'C9', 'available', NULL, 2, NULL, NULL, NULL, '2025-07-10 03:31:41'),
(156, 'C10', 'available', NULL, 2, NULL, NULL, NULL, '2025-07-10 03:31:41');

-- --------------------------------------------------------

--
-- Table structure for table `sessions`
--

CREATE TABLE `sessions` (
  `id` int(11) NOT NULL,
  `session_name` varchar(50) NOT NULL COMMENT 'e.g., 2024-2025',
  `is_active` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `sessions`
--

INSERT INTO `sessions` (`id`, `session_name`, `is_active`, `created_at`) VALUES
(1, '2025-2026', 1, '2025-07-09 19:02:16'),
(2, '2026-2027', 0, '2025-07-09 19:02:44');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `role` enum('admin','user') NOT NULL DEFAULT 'user',
  `full_name` varchar(100) DEFAULT NULL,
  `guardian_name` varchar(100) DEFAULT NULL,
  `address` text DEFAULT NULL,
  `phone_number` varchar(20) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `date_of_birth` date DEFAULT NULL,
  `date_of_joining_library` date DEFAULT NULL,
  `avatar_path` varchar(255) DEFAULT 'uploads/avatars/default.png',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `username`, `password`, `role`, `full_name`, `guardian_name`, `address`, `phone_number`, `email`, `date_of_birth`, `date_of_joining_library`, `avatar_path`, `created_at`) VALUES
(1, 'admin', '$2y$10$81XsXAXR7sRpw6E6PgWDHO8SvMFiWxGEr7v3HswftPS0ZZFkjKGR6', 'admin', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'uploads/avatars/default.png', '2025-07-09 17:04:13'),
(2, 'testuser', '$2y$10$MXcIdkKFUXYFwLBOtNK6a.49eNpU/4nvK0CwFlaXSPdHwMCGvA.CG', 'user', 'Himanshu Singh', 'himanshu_guardian', 'kanpur', '8948324461', 'himanshusingh1814@gmail.com', '2003-10-10', '2025-02-10', 'uploads/avatars/default.png', '2025-07-09 17:04:13'),
(3, 'Prakhar01', '$2y$10$gJNYjAqzWGOX9Mt6mER3GuZb4caZRMyhrSJQOzeqtJvomIDHY0f3S', 'user', 'Prakhar Datt Rai', 'Mr.Nagendra Datt  Rai', 'Parsauni jaura bazar kushinagar', '9808582401', 'prakhardattrai@gmail.com', '2007-01-01', '2025-07-10', 'uploads/avatars/default.png', '2025-07-10 03:55:15'),
(4, 'ashish01', '$2y$10$FUA3x/5zPeTnx0UyaW.Bau6gJ4HPVAcMLmUcCJwoFZwxuclAwWmZm', 'user', 'ashish singh', 'anup singh', '', '6307215600', 'ashishsingh@gmail.com', '2008-06-27', '2025-07-10', 'uploads/avatars/default.png', '2025-07-10 03:56:53'),
(5, 'Gulshan Kumar', '$2y$10$vTH98EYQPABdckaAyulB8erzgjeofn5ckmaQ70To1ylsI71mGf5Ci', 'user', NULL, NULL, NULL, NULL, NULL, NULL, '2025-07-10', 'uploads/avatars/default.png', '2025-07-10 04:04:08');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `payments`
--
ALTER TABLE `payments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `session_id` (`session_id`);

--
-- Indexes for table `seats`
--
ALTER TABLE `seats`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_seat_per_session` (`seat_number`,`session_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `requested_by_id` (`requested_by_id`),
  ADD KEY `fk_session_id` (`session_id`);

--
-- Indexes for table `sessions`
--
ALTER TABLE `sessions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `session_name` (`session_name`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `payments`
--
ALTER TABLE `payments`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `seats`
--
ALTER TABLE `seats`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=157;

--
-- AUTO_INCREMENT for table `sessions`
--
ALTER TABLE `sessions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `payments`
--
ALTER TABLE `payments`
  ADD CONSTRAINT `payments_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `payments_ibfk_2` FOREIGN KEY (`session_id`) REFERENCES `sessions` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `seats`
--
ALTER TABLE `seats`
  ADD CONSTRAINT `fk_session_id` FOREIGN KEY (`session_id`) REFERENCES `sessions` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `seats_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `seats_ibfk_2` FOREIGN KEY (`requested_by_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
