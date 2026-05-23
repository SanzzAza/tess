CREATE DATABASE IF NOT EXISTS zynetra_rp;
USE zynetra_rp;

CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(24) NOT NULL UNIQUE,
    password VARCHAR(128) NOT NULL,
    money INT DEFAULT 5000,
    level INT DEFAULT 1,
    admin INT DEFAULT 0,
    faction INT DEFAULT 0,
    faction_rank INT DEFAULT 0,
    job INT DEFAULT 0,
    house_id INT DEFAULT 0,
    last_x FLOAT DEFAULT 1685.8284,
    last_y FLOAT DEFAULT -2333.0125,
    last_z FLOAT DEFAULT 13.5469,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS inventory (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    item_name VARCHAR(32) NOT NULL,
    amount INT DEFAULT 1
);

CREATE TABLE IF NOT EXISTS factions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(64) NOT NULL,
    type VARCHAR(32) NOT NULL
);

CREATE TABLE IF NOT EXISTS houses (
    id INT AUTO_INCREMENT PRIMARY KEY,
    owner_id INT DEFAULT 0,
    price INT NOT NULL,
    x FLOAT NOT NULL,
    y FLOAT NOT NULL,
    z FLOAT NOT NULL
);

CREATE TABLE IF NOT EXISTS vehicles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    owner_id INT NOT NULL,
    model INT NOT NULL,
    plate VARCHAR(16) DEFAULT 'ZYN',
    color1 INT DEFAULT 1,
    color2 INT DEFAULT 1
);

CREATE TABLE IF NOT EXISTS jobs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(64) NOT NULL,
    salary INT DEFAULT 1000
);

INSERT IGNORE INTO factions (id, name, type) VALUES
(1, 'Police Department', 'law'),
(2, 'Emergency Medical Service', 'medical'),
(3, 'Government', 'gov');

INSERT IGNORE INTO jobs (id, name, salary) VALUES
(1, 'Courier', 750),
(2, 'Mechanic', 1000),
(3, 'Miner', 900);

INSERT IGNORE INTO houses (id, owner_id, price, x, y, z) VALUES
(1, 0, 100000, 1684.9, -2240.2, 13.5);
