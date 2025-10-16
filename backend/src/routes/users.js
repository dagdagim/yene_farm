import express from 'express';
import bcrypt from 'bcryptjs';
import pkg from 'pg';
const { Pool } = pkg;
import Joi from 'joi';
import { requireAuth, requireUserType } from '../middleware/auth.js';
import { validateBody } from '../middleware/index.js';

const router = express.Router();

// Database connection
const pool = new Pool({
    connectionString: process.env.DATABASE_URL || 'postgres://postgres:password@localhost:5432/yene_farm'
});

// Validation schemas
const updateProfileSchema = Joi.object({
    firstName: Joi.string().min(2).max(50).optional(),
    lastName: Joi.string().min(2).max(50).optional(),
    phone: Joi.string().optional(),
    address: Joi.object().optional(),
    profileImage: Joi.string().uri().optional()
});

const changePasswordSchema = Joi.object({
    currentPassword: Joi.string().required(),
    newPassword: Joi.string().min(6).required()
});

// GET /api/users/profile - Get current user profile
router.get('/profile', requireAuth, async (req, res) => {
    try {
        const result = await pool.query(
            `SELECT id, email, first_name, last_name, phone, user_type, profile_image, 
                    address, is_verified, is_active, created_at, updated_at 
             FROM users WHERE id = $1`,
            [req.user.id]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ error: 'User not found' });
        }

        const user = result.rows[0];
        res.json({
            id: user.id,
            email: user.email,
            firstName: user.first_name,
            lastName: user.last_name,
            phone: user.phone,
            userType: user.user_type,
            profileImage: user.profile_image,
            address: user.address,
            isVerified: user.is_verified,
            isActive: user.is_active,
            createdAt: user.created_at,
            updatedAt: user.updated_at
        });

    } catch (err) {
        console.error('Get profile error:', err);
        res.status(500).json({ error: 'Internal server error' });
    }
});

// PUT /api/users/profile - Update user profile
router.put('/profile', requireAuth, validateBody(updateProfileSchema), async (req, res) => {
    try {
        const { firstName, lastName, phone, address, profileImage } = req.body;
        
        const updateFields = [];
        const values = [];
        let paramCount = 1;

        if (firstName !== undefined) {
            updateFields.push(`first_name = $${paramCount++}`);
            values.push(firstName);
        }
        if (lastName !== undefined) {
            updateFields.push(`last_name = $${paramCount++}`);
            values.push(lastName);
        }
        if (phone !== undefined) {
            updateFields.push(`phone = $${paramCount++}`);
            values.push(phone);
        }
        if (address !== undefined) {
            updateFields.push(`address = $${paramCount++}`);
            values.push(JSON.stringify(address));
        }
        if (profileImage !== undefined) {
            updateFields.push(`profile_image = $${paramCount++}`);
            values.push(profileImage);
        }

        if (updateFields.length === 0) {
            return res.status(400).json({ error: 'No fields to update' });
        }

        updateFields.push(`updated_at = now()`);
        values.push(req.user.id);

        const query = `
            UPDATE users 
            SET ${updateFields.join(', ')} 
            WHERE id = $${paramCount} 
            RETURNING id, email, first_name, last_name, phone, user_type, profile_image, address, updated_at
        `;

        const result = await pool.query(query, values);

        if (result.rows.length === 0) {
            return res.status(404).json({ error: 'User not found' });
        }

        const user = result.rows[0];
        res.json({
            message: 'Profile updated successfully',
            user: {
                id: user.id,
                email: user.email,
                firstName: user.first_name,
                lastName: user.last_name,
                phone: user.phone,
                userType: user.user_type,
                profileImage: user.profile_image,
                address: user.address,
                updatedAt: user.updated_at
            }
        });

    } catch (err) {
        console.error('Update profile error:', err);
        res.status(500).json({ error: 'Internal server error' });
    }
});

// PUT /api/users/change-password - Change user password
router.put('/change-password', requireAuth, validateBody(changePasswordSchema), async (req, res) => {
    try {
        const { currentPassword, newPassword } = req.body;

        // Get current password hash
        const result = await pool.query(
            'SELECT password_hash FROM users WHERE id = $1',
            [req.user.id]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ error: 'User not found' });
        }

        // Verify current password
        const isValidPassword = await bcrypt.compare(currentPassword, result.rows[0].password_hash);
        if (!isValidPassword) {
            return res.status(400).json({ error: 'Current password is incorrect' });
        }

        // Hash new password
        const saltRounds = 12;
        const newPasswordHash = await bcrypt.hash(newPassword, saltRounds);

        // Update password
        await pool.query(
            'UPDATE users SET password_hash = $1, updated_at = now() WHERE id = $2',
            [newPasswordHash, req.user.id]
        );

        res.json({ message: 'Password changed successfully' });

    } catch (err) {
        console.error('Change password error:', err);
        res.status(500).json({ error: 'Internal server error' });
    }
});

// GET /api/users/:id - Get user by ID (public info only)
router.get('/:id', async (req, res) => {
    try {
        const { id } = req.params;

        const result = await pool.query(
            `SELECT id, first_name, last_name, user_type, profile_image, created_at 
             FROM users WHERE id = $1 AND is_active = true`,
            [id]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ error: 'User not found' });
        }

        const user = result.rows[0];
        res.json({
            id: user.id,
            firstName: user.first_name,
            lastName: user.last_name,
            userType: user.user_type,
            profileImage: user.profile_image,
            memberSince: user.created_at
        });

    } catch (err) {
        console.error('Get user error:', err);
        res.status(500).json({ error: 'Internal server error' });
    }
});

// GET /api/users/farmers - Get all farmers (for buyers to browse)
router.get('/farmers', async (req, res) => {
    try {
        const page = parseInt(req.query.page) || 1;
        const limit = parseInt(req.query.limit) || 20;
        const offset = (page - 1) * limit;

        const result = await pool.query(
            `SELECT id, first_name, last_name, profile_image, created_at,
                    (SELECT COUNT(*) FROM products WHERE seller_id = users.id AND is_available = true) as product_count
             FROM users 
             WHERE user_type = 'farmer' AND is_active = true 
             ORDER BY created_at DESC 
             LIMIT $1 OFFSET $2`,
            [limit, offset]
        );

        const countResult = await pool.query(
            'SELECT COUNT(*) FROM users WHERE user_type = \'farmer\' AND is_active = true'
        );

        const totalCount = parseInt(countResult.rows[0].count);
        const totalPages = Math.ceil(totalCount / limit);

        res.json({
            farmers: result.rows.map(user => ({
                id: user.id,
                firstName: user.first_name,
                lastName: user.last_name,
                profileImage: user.profile_image,
                memberSince: user.created_at,
                productCount: parseInt(user.product_count)
            })),
            pagination: {
                currentPage: page,
                totalPages,
                totalCount,
                hasNext: page < totalPages,
                hasPrev: page > 1
            }
        });

    } catch (err) {
        console.error('Get farmers error:', err);
        res.status(500).json({ error: 'Internal server error' });
    }
});

// DELETE /api/users/profile - Deactivate user account
router.delete('/profile', requireAuth, async (req, res) => {
    try {
        await pool.query(
            'UPDATE users SET is_active = false, updated_at = now() WHERE id = $1',
            [req.user.id]
        );

        res.json({ message: 'Account deactivated successfully' });

    } catch (err) {
        console.error('Deactivate account error:', err);
        res.status(500).json({ error: 'Internal server error' });
    }
});

export default router;