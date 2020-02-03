/* Create a users table */
CREATE TABLE IF NOT EXISTS `users` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

/* Insert some records */
INSERT INTO users(username) VALUES ('Bob') ON DUPLICATE KEY UPDATE username = 'Bob';