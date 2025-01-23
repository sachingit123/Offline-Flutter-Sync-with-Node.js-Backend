// server.js (Single Page for All Tasks with Address Table)
const express = require('express');
const bodyParser = require('body-parser');
const mysql = require('mysql2');

const app = express();
app.use(bodyParser.json());

// MySQL Connection
const db = mysql.createConnection({
  host: 'localhost',
  user: 'root',
  port: 3306,
  password: 'Deepak123',
  database: 'userdb',
});

db.connect((err) => {
  if (err) {
    console.error('Error connecting to MySQL:', err);
    return;
  }
  console.log('Connected to MySQL database');
});

// Create Tables (Run once or use migrations)
db.query(
  `CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    location VARCHAR(255) NOT NULL,
    synced BOOLEAN DEFAULT FALSE
  )`,
  (err) => {
    if (err) {
      console.error('Error creating users table:', err);
    } else {
      console.log('Users table ready');
    }
  }
);

db.query(
  `CREATE TABLE IF NOT EXISTS addresses (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    house VARCHAR(255) NOT NULL,
    apartment VARCHAR(255),
    fullAddress VARCHAR(255) NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
  )`,
  (err) => {
    if (err) {
      console.error('Error creating addresses table:', err);
    } else {
      console.log('Addresses table ready');
    }
  }
);

// Endpoints

// Get all users
app.get('/users', (req, res) => {
  db.query('SELECT * FROM users', (err, results) => {
    if (err) {
      res.status(500).json({ error: err });
    } else {
      res.json(results);
    }
  });
});

// Add a new user
app.post('/users', (req, res) => {
  const { name, email, location } = req.body;
  db.query(
    'INSERT INTO users (name, email, location, synced) VALUES (?, ?, ?, ?)',
    [name, email, location, false],
    (err, result) => {
      if (err) {
        res.status(500).json({ error: err });
      } else {
        res.status(201).json({ id: result.insertId });
      }
    }
  );
});

// Get all addresses
app.get('/addresses', (req, res) => {
  db.query('SELECT * FROM addresses', (err, results) => {
    if (err) {
      res.status(500).json({ error: err });
    } else {
      res.json(results);
    }
  });
});

// Add a new address
app.post('/addresses', (req, res) => {
  const { user_id, house, apartment, fullAddress } = req.body;
  db.query(
    'INSERT INTO addresses (user_id, house, apartment, fullAddress) VALUES (?, ?, ?, ?)',
    [user_id, house, apartment, fullAddress],
    (err, result) => {
      if (err) {
        res.status(500).json({ error: err });
      } else {
        res.status(201).json({ id: result.insertId });
      }
    }
  );
});

// Start Server
const PORT = 3000;
app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});
