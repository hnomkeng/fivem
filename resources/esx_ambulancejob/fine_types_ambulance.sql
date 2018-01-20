CREATE TABLE `fine_types_ambulance` (
  `id` int(11) NOT NULL,
  `label` varchar(255) DEFAULT NULL,
  `amount` int(11) DEFAULT NULL,
  `category` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


INSERT INTO `fine_types_ambulance` (`id`, `label`, `amount`, `category`) VALUES
(1, 'Care for a member of the police', 400, 0),
(2, ' Basic treatment', 500, 0),
(3, 'Long distance care', 750, 0),
(4, 'Unconscious patient care', 800, 0);


ALTER TABLE `fine_types_ambulance`
  ADD PRIMARY KEY (`id`);