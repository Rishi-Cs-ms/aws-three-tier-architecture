const mysql = require('mysql2');

const pool = mysql.createPool({
  host: 'mysql-app-db.chek4qyo0ytb.ca-central-1.rds.amazonaws.com',
  user: 'admin',
  password: 'YPQ&r[BAw:C=JL1-',
  multipleStatements: true
});

const schema = `
CREATE DATABASE IF NOT EXISTS demo_db;

USE demo_db;

CREATE TABLE IF NOT EXISTS users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
`;

const connection = pool.getConnection((err, conn) => {
  if (err) {
    console.error('Connection error:', err);
    process.exit(1);
  }
  
  conn.query(schema, (err) => {
    if (err) {
      console.error('SQL error:', err);
      process.exit(1);
    }
    console.log('Database and table created successfully!');
    conn.release();
    pool.end();
  });
});
