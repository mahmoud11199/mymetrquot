CREATE TABLE Users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(100) NOT NULL UNIQUE,
  email VARCHAR(255) UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  role ENUM('rider','driver','admin') NOT NULL DEFAULT 'rider',
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE DriverProfiles (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL UNIQUE,
  license_number VARCHAR(100) NOT NULL,
  verification_status ENUM('pending','approved','rejected') NOT NULL DEFAULT 'pending',
  rating_avg DECIMAL(3,2) DEFAULT 0,
  total_trips INT DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES Users(id)
);

CREATE TABLE Vehicles (
  id INT AUTO_INCREMENT PRIMARY KEY,
  driver_profile_id INT NOT NULL,
  make VARCHAR(80) NOT NULL,
  model VARCHAR(80) NOT NULL,
  plate_number VARCHAR(50) NOT NULL UNIQUE,
  color VARCHAR(50),
  seats INT DEFAULT 4,
  status ENUM('active','inactive') DEFAULT 'active',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (driver_profile_id) REFERENCES DriverProfiles(id)
);

CREATE TABLE RideRequests (
  id INT AUTO_INCREMENT PRIMARY KEY,
  rider_id INT NOT NULL,
  pickup_lat DECIMAL(10,7) NOT NULL,
  pickup_lng DECIMAL(10,7) NOT NULL,
  dropoff_lat DECIMAL(10,7) NOT NULL,
  dropoff_lng DECIMAL(10,7) NOT NULL,
  pickup_address VARCHAR(255),
  dropoff_address VARCHAR(255),
  estimated_fare DECIMAL(10,2),
  status ENUM('pending','offered','accepted','cancelled','expired') DEFAULT 'pending',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (rider_id) REFERENCES Users(id)
);

CREATE TABLE Offers (
  id INT AUTO_INCREMENT PRIMARY KEY,
  ride_request_id INT NOT NULL,
  driver_id INT NOT NULL,
  proposed_fare DECIMAL(10,2) NOT NULL,
  message VARCHAR(500),
  status ENUM('pending','accepted','rejected','withdrawn') DEFAULT 'pending',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (ride_request_id) REFERENCES RideRequests(id),
  FOREIGN KEY (driver_id) REFERENCES Users(id)
);

CREATE TABLE Trips (
  id INT AUTO_INCREMENT PRIMARY KEY,
  ride_request_id INT,
  rider_id INT NOT NULL,
  driver_id INT NOT NULL,
  offer_id INT,
  distance_km DECIMAL(10,2) DEFAULT 0,
  duration_sec INT DEFAULT 0,
  fare DECIMAL(10,2) NOT NULL,
  status ENUM('created','driver_arriving','in_progress','completed','cancelled') DEFAULT 'created',
  started_at DATETIME NULL,
  completed_at DATETIME NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (ride_request_id) REFERENCES RideRequests(id),
  FOREIGN KEY (rider_id) REFERENCES Users(id),
  FOREIGN KEY (driver_id) REFERENCES Users(id),
  FOREIGN KEY (offer_id) REFERENCES Offers(id)
);

CREATE TABLE Messages (
  id INT AUTO_INCREMENT PRIMARY KEY,
  ride_request_id INT NOT NULL,
  sender_id INT NOT NULL,
  receiver_id INT NOT NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (ride_request_id) REFERENCES RideRequests(id),
  FOREIGN KEY (sender_id) REFERENCES Users(id),
  FOREIGN KEY (receiver_id) REFERENCES Users(id)
);

CREATE TABLE Ratings (
  id INT AUTO_INCREMENT PRIMARY KEY,
  trip_id INT NOT NULL,
  rater_id INT NOT NULL,
  ratee_id INT NOT NULL,
  score TINYINT NOT NULL,
  comment VARCHAR(500),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (trip_id) REFERENCES Trips(id),
  FOREIGN KEY (rater_id) REFERENCES Users(id),
  FOREIGN KEY (ratee_id) REFERENCES Users(id)
);

CREATE TABLE Disputes (
  id INT AUTO_INCREMENT PRIMARY KEY,
  trip_id INT NOT NULL,
  reported_by INT NOT NULL,
  reason VARCHAR(500) NOT NULL,
  status ENUM('open','under_review','resolved','rejected') DEFAULT 'open',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (trip_id) REFERENCES Trips(id),
  FOREIGN KEY (reported_by) REFERENCES Users(id)
);

CREATE TABLE Documents (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  document_type VARCHAR(80) NOT NULL,
  file_url VARCHAR(255) NOT NULL,
  verification_status ENUM('pending','approved','rejected') DEFAULT 'pending',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES Users(id)
);

CREATE TABLE Notifications (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  title VARCHAR(150) NOT NULL,
  body VARCHAR(500) NOT NULL,
  type VARCHAR(80) NOT NULL,
  is_read TINYINT(1) NOT NULL DEFAULT 0,
  metadata_json JSON,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES Users(id)
);

CREATE TABLE AuditLogs (
  id INT AUTO_INCREMENT PRIMARY KEY,
  actor_user_id INT,
  action VARCHAR(120) NOT NULL,
  entity_type VARCHAR(80) NOT NULL,
  entity_id INT,
  details_json JSON,
  ip_address VARCHAR(64),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (actor_user_id) REFERENCES Users(id)
);

CREATE TABLE Locations (
  id INT AUTO_INCREMENT PRIMARY KEY,
  trip_id INT NOT NULL,
  user_id INT NOT NULL,
  lat DECIMAL(10,7) NOT NULL,
  lng DECIMAL(10,7) NOT NULL,
  speed_kmh DECIMAL(6,2) DEFAULT 0,
  heading DECIMAL(6,2) DEFAULT 0,
  captured_at DATETIME NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (trip_id) REFERENCES Trips(id),
  FOREIGN KEY (user_id) REFERENCES Users(id)
);

CREATE TABLE Settings (
  `key` VARCHAR(120) PRIMARY KEY,
  `value` TEXT NOT NULL,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Demo seed users (password: password123)
INSERT INTO Users (username, email, password_hash, role)
VALUES
('rider1', 'rider1@example.com', '$2y$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'rider'),
('driver1', 'driver1@example.com', '$2y$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'driver'),
('admin1', 'admin1@example.com', '$2y$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'admin');
