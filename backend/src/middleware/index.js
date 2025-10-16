import morgan from 'morgan';
import rateLimit from 'express-rate-limit';
import helmet from 'helmet';
import Joi from 'joi';
import { requireAuth, requireUserType, requireAdmin, optionalAuth } from './auth.js';

// Security middleware
const securityMiddleware = helmet({
    contentSecurityPolicy: {
        directives: {
            defaultSrc: ["'self'"],
            styleSrc: ["'self'", "'unsafe-inline'"],
            scriptSrc: ["'self'"],
            imgSrc: ["'self'", "data:", "https:"],
        },
    },
});

// Request logger using morgan
const requestLogger = morgan('combined');

// Global rate limiter
const rateLimiter = rateLimit({
    windowMs: 60 * 1000, // 1 minute
    max: 100, // limit each IP to 100 requests per windowMs
    standardHeaders: true,
    legacyHeaders: false,
    message: {
        error: 'Too many requests from this IP, please try again later.'
    }
});

// Auth rate limiter (stricter for auth endpoints)
const authRateLimiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 5, // limit each IP to 5 requests per windowMs
    standardHeaders: true,
    legacyHeaders: false,
    message: {
        error: 'Too many authentication attempts, please try again later.'
    }
});

// Validation middleware factory using Joi schema
function validateBody(schema) {
    return (req, res, next) => {
        const { error, value } = schema.validate(req.body, { 
            abortEarly: false, 
            stripUnknown: true,
            allowUnknown: false
        });
        if (error) {
            return res.status(400).json({ 
                error: 'validation_error', 
                details: error.details.map(d => d.message) 
            });
        }
        req.body = value;
        next();
    };
}

// Error handling middleware
function errorHandler(err, req, res, next) {
    console.error('Error:', err);
    
    if (err.name === 'ValidationError') {
        return res.status(400).json({ error: 'Validation error', details: err.message });
    }
    
    if (err.name === 'UnauthorizedError') {
        return res.status(401).json({ error: 'Unauthorized' });
    }
    
    res.status(500).json({ error: 'Internal server error' });
}

// 404 handler
function notFoundHandler(req, res) {
    res.status(404).json({ error: 'Route not found' });
}

export {
    securityMiddleware,
    requestLogger,
    rateLimiter,
    authRateLimiter,
    validateBody,
    requireAuth,
    requireUserType,
    requireAdmin,
    optionalAuth,
    errorHandler,
    notFoundHandler
};
