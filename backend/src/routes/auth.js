import express from 'express';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import pkg from 'pg';
const { Pool } = pkg;
import Joi from 'joi';

const router = express.Router();

// Database connection
const pool = new Pool({
    connectionString: process.env.DATABASE_URL || 'postgres://postgres:password@localhost:5432/yene_farm'
});

// JWT Secret
const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key';

// Validation schemas
const signupSchema = Joi.object({
    email: Joi.string().email().required(),
    password: Joi.string().min(6).required(),
    firstName: Joi.string().min(2).max(50).required(),
    lastName: Joi.string().min(2).max(50).required(),
    phone: Joi.string().optional(),
    userType: Joi.string().valid('farmer', 'buyer').required(),
    address: Joi.object().optional()
});

const loginSchema = Joi.object({
    email: Joi.string().email().required(),
    password: Joi.string().required()
});

// POST /api/auth/signup - User registration
router.post('/signup', async (req, res) => {
    try {
        const { error, value } = signupSchema.validate(req.body);
        if (error) {
            return res.status(400).json({ 
                error: 'validation_error', 
                details: error.details.map(d => d.message) 
            });
        }

        const { email, password, firstName, lastName, phone, userType, address } = value;

        // Check if user already exists
        const existingUser = await pool.query('SELECT id FROM users WHERE email = $1', [email]);
        if (existingUser.rows.length > 0) {
            return res.status(409).json({ error: 'User already exists with this email' });
        }

        // Hash password
        const saltRounds = 12;
        const passwordHash = await bcrypt.hash(password, saltRounds);

        // Create user
        const result = await pool.query(
            `INSERT INTO users (email, password_hash, first_name, last_name, phone, user_type, address)
             VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING id, email, first_name, last_name, user_type, created_at`,
            [email, passwordHash, firstName, lastName, phone, userType, JSON.stringify(address || {})]
        );

        const user = result.rows[0];

        // Generate JWT token
        const token = jwt.sign(
            { 
                userId: user.id, 
                email: user.email, 
                userType: user.user_type 
            },
            JWT_SECRET,
            { expiresIn: '7d' }
        );

        res.status(201).json({
            message: 'User created successfully',
            user: {
                id: user.id,
                email: user.email,
                firstName: user.first_name,
                lastName: user.last_name,
                userType: user.user_type,
                createdAt: user.created_at
            },
            token
        });

    } catch (err) {
        console.error('Signup error:', err);
        res.status(500).json({ error: 'Internal server error' });
    }
});

// POST /api/auth/login - User login
router.post('/login', async (req, res) => {
    try {
        const { error, value } = loginSchema.validate(req.body);
        if (error) {
            return res.status(400).json({ 
                error: 'validation_error', 
                details: error.details.map(d => d.message) 
            });
        }

        const { email, password } = value;

        // Find user
        const result = await pool.query(
            'SELECT id, email, password_hash, first_name, last_name, user_type, is_active FROM users WHERE email = $1',
            [email]
        );

        if (result.rows.length === 0) {
            return res.status(401).json({ error: 'Invalid email or password' });
        }

        const user = result.rows[0];

        // Check if user is active
        if (!user.is_active) {
            return res.status(401).json({ error: 'Account is deactivated' });
        }

        // Verify password
        const isValidPassword = await bcrypt.compare(password, user.password_hash);
        if (!isValidPassword) {
            return res.status(401).json({ error: 'Invalid email or password' });
        }

        // Generate JWT token
        const token = jwt.sign(
            { 
                userId: user.id, 
                email: user.email, 
                userType: user.user_type 
            },
            JWT_SECRET,
            { expiresIn: '7d' }
        );

        res.json({
            message: 'Login successful',
            user: {
                id: user.id,
                email: user.email,
                firstName: user.first_name,
                lastName: user.last_name,
                userType: user.user_type
            },
            token
        });

    } catch (err) {
        console.error('Login error:', err);
        res.status(500).json({ error: 'Internal server error' });
    }
});

// POST /api/auth/verify - Verify JWT token
router.post('/verify', async (req, res) => {
    try {
        const { token } = req.body;
        if (!token) {
            return res.status(400).json({ error: 'Token required' });
        }

        // Verify token
        const decoded = jwt.verify(token, JWT_SECRET);
        
        // Get user details
        const result = await pool.query(
            'SELECT id, email, first_name, last_name, user_type, is_active FROM users WHERE id = $1',
            [decoded.userId]
        );

        if (result.rows.length === 0) {
            return res.status(401).json({ error: 'User not found' });
        }

        const user = result.rows[0];
        if (!user.is_active) {
            return res.status(401).json({ error: 'Account is deactivated' });
        }

        res.json({
            user: {
                id: user.id,
                email: user.email,
                firstName: user.first_name,
                lastName: user.last_name,
                userType: user.user_type
            }
        });

    } catch (err) {
        if (err.name === 'JsonWebTokenError') {
            return res.status(401).json({ error: 'Invalid token' });
        }
        if (err.name === 'TokenExpiredError') {
            return res.status(401).json({ error: 'Token expired' });
        }
        console.error('Token verification error:', err);
        res.status(500).json({ error: 'Internal server error' });
    }
});

// POST /api/auth/logout - Logout (client-side token removal)
router.post('/logout', (req, res) => {
    res.json({ message: 'Logout successful' });
});

export default router;
