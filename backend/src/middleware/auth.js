import jwt from 'jsonwebtoken';
import pkg from 'pg';
const { Pool } = pkg;

const pool = new Pool({
    connectionString: process.env.DATABASE_URL || 'postgres://postgres:password@localhost:5432/yene_farm'
});

const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key';

async function requireAuth(req, res, next) {
    try {
        const auth = req.headers.authorization;
        if (!auth || !auth.startsWith('Bearer ')) {
            return res.status(401).json({ error: 'Missing or invalid authorization header' });
        }
        
        const token = auth.split(' ')[1];
        
        // Verify JWT token
        const decoded = jwt.verify(token, JWT_SECRET);
        
        // Get user from database
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
        
        req.user = {
            id: user.id,
            email: user.email,
            firstName: user.first_name,
            lastName: user.last_name,
            userType: user.user_type
        };
        
        next();
    } catch (err) {
        if (err.name === 'JsonWebTokenError') {
            return res.status(401).json({ error: 'Invalid token' });
        }
        if (err.name === 'TokenExpiredError') {
            return res.status(401).json({ error: 'Token expired' });
        }
        console.error('Auth middleware error:', err);
        res.status(500).json({ error: 'Authentication error' });
    }
}

// Require specific user type (farmer, buyer, admin)
function requireUserType(allowedTypes) {
    return (req, res, next) => {
        if (!req.user) {
            return res.status(401).json({ error: 'Authentication required' });
        }
        
        if (!allowedTypes.includes(req.user.userType)) {
            return res.status(403).json({ 
                error: 'Insufficient permissions',
                required: allowedTypes,
                current: req.user.userType
            });
        }
        
        next();
    };
}

// Require admin access
function requireAdmin(req, res, next) {
    try {
        // Check if user is admin
        if (req.user && req.user.userType === 'admin') {
            return next();
        }
        
        // Fallback: API key in header
        const adminKey = process.env.ADMIN_API_KEY;
        const provided = req.headers['x-admin-key'] || req.query.admin_key;
        if (adminKey && provided && provided === adminKey) {
            return next();
        }
        
        return res.status(403).json({ error: 'Admin access required' });
    } catch (err) {
        console.error('requireAdmin error:', err);
        res.status(500).json({ error: 'Server error' });
    }
}

// Optional auth - doesn't fail if no token provided
async function optionalAuth(req, res, next) {
    try {
        const auth = req.headers.authorization;
        if (!auth || !auth.startsWith('Bearer ')) {
            req.user = null;
            return next();
        }
        
        const token = auth.split(' ')[1];
        const decoded = jwt.verify(token, JWT_SECRET);
        
        const result = await pool.query(
            'SELECT id, email, first_name, last_name, user_type, is_active FROM users WHERE id = $1',
            [decoded.userId]
        );
        
        if (result.rows.length > 0 && result.rows[0].is_active) {
            const user = result.rows[0];
            req.user = {
                id: user.id,
                email: user.email,
                firstName: user.first_name,
                lastName: user.last_name,
                userType: user.user_type
            };
        } else {
            req.user = null;
        }
        
        next();
    } catch (err) {
        // If token is invalid, just set user to null and continue
        req.user = null;
        next();
    }
}

export { requireAuth, requireUserType, requireAdmin, optionalAuth };
