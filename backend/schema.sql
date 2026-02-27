CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(100) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL
);

CREATE TABLE trips (
  id INT AUTO_INCREMENT PRIMARY KEY,
  distance FLOAT NOT NULL,
  duration INT NOT NULL,
  fare FLOAT NOT NULL,
  date VARCHAR(50) NOT NULL
);

-- Example user with password "password123"
INSERT INTO users (username, password_hash)
VALUES ('driver1', '$2y$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy');
