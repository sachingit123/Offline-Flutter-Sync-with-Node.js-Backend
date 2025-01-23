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
  password: 'Deepak123', // Use your actual password
  database: 'jobdb', // The database name is 'jobdb'
});

db.connect((err) => {
  if (err) {
    console.error('Error connecting to MySQL:', err);
    return;
  }
  console.log('Connected to MySQL database');
});

// Create 'job' Table
db.query(
  `CREATE TABLE IF NOT EXISTS jobs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    visitMode VARCHAR(255) NOT NULL,
    startDate DATE NOT NULL,
    visitStartFromState VARCHAR(255) NOT NULL,
    cityName VARCHAR(255) NOT NULL
  )`,
  (err) => {
    if (err) {
      console.error('Error creating jobs table:', err);
    } else {
      console.log('Job table ready');
    }
  }
);

// Endpoints

// Get All Visits
app.get('/jobs', (req, res) => {
  db.query('SELECT * FROM jobs', (err, results) => {
    if (err) {
      res.status(500).json({ error: err });
    } else {
      res.json(results);
    }
  });
});

// Add a New Visit
app.post('/jobs', (req, res) => {
  const { visitMode, startDate, visitStartFromState, cityName } = req.body;

  // Validate input
  if (!visitMode || !startDate || !visitStartFromState || !cityName) {
    return res.status(400).json({ error: 'All fields are required' });
  }

  db.query(
    'INSERT INTO jobs (visitMode, startDate, visitStartFromState, cityName) VALUES (?, ?, ?, ?)',
    [visitMode, startDate, visitStartFromState, cityName],
    (err, result) => {
      if (err) {
        res.status(500).json({ error: err });
      } else {
        res.status(201).json({ message: 'Job added successfully', id: result.insertId });
      }
    }
  );
});

// Start Server
const PORT = 3000;
app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});
