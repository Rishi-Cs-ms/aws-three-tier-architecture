require('dotenv').config();
const express = require('express');
const cors = require('cors');
const db = require('./db');

const app = express();

// CORS: allow the frontend origin (configured via env or default)
const FRONTEND_ORIGINS = [process.env.FRONTEND_ORIGIN || 'https://three-tier-demo-backend.rishimajmudar.me', 'https://d1j86t7izf9l0w.cloudfront.net'];

app.use(cors({
    origin: (origin, callback) => {
        // allow non-browser tools (no origin) and allowed origins
        if (!origin) return callback(null, true);
        if (FRONTEND_ORIGINS.includes(origin)) return callback(null, true);
        return callback(new Error('Not allowed by CORS'), false);
    },
    methods: ["GET", "POST", "PUT", "DELETE"],
    allowedHeaders: ["Content-Type"],
}));

const port = 3000;

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Initialize database on startup
async function initDatabase() {
    try {
        // Create database if it doesn't exist
        await db.query('CREATE DATABASE IF NOT EXISTS demo_db');
        
        // Select the database
        await db.query('USE demo_db');
        
        // Create users table if it doesn't exist
        await db.query(`
            CREATE TABLE IF NOT EXISTS users (
                id INT AUTO_INCREMENT PRIMARY KEY,
                name VARCHAR(255) NOT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        `);
        
        console.log('Database and table initialized successfully');
    } catch (err) {
        console.error('Database initialization error:', err);
        // Don't exit, the server will handle errors gracefully
    }
}

// Health check for ALB
app.get('/', (req, res) => {
    res.status(200).send('App running');
});

// Get all users
app.get('/users', async (req, res) => {
    try {
        const [rows] = await db.query('SELECT * FROM users');
        res.json(rows);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Database error' });
    }
});

// Add a user
app.post('/add', async (req, res) => {
    const { name } = req.body;
    if (!name) {
        return res.status(400).json({ error: 'Name is required' });
    }

    try {
        const [result] = await db.query('INSERT INTO users (name) VALUES (?)', [name]);
        res.status(201).json({ id: result.insertId, name });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Database error' });
    }
});

// Update a user
app.put('/update/:id', async (req, res) => {
    const { id } = req.params;
    const { name } = req.body;
    if (!name) {
        return res.status(400).json({ error: 'Name is required' });
    }

    try {
        const [result] = await db.query('UPDATE users SET name = ? WHERE id = ?', [name, id]);
        if (result.affectedRows === 0) {
            return res.status(404).json({ error: 'User not found' });
        }
        res.json({ id, name, message: 'User updated' });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Database error' });
    }
});

// Delete a user
app.delete('/delete/:id', async (req, res) => {
    const { id } = req.params;
    try {
        const [result] = await db.query('DELETE FROM users WHERE id = ?', [id]);
        if (result.affectedRows === 0) {
            return res.status(404).json({ error: 'User not found' });
        }
        res.json({ message: 'User deleted' });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Database error' });
    }
});

// Start server and initialize database
app.listen(port, async () => {
    console.log(`Server running on port ${port}`);
    await initDatabase();
});
