import express from 'express';
import pkg from 'pg';
const { Pool } = pkg;
import Joi from 'joi';
import { requireAuth, requireUserType, optionalAuth } from '../middleware/auth.js';
import { validateBody } from '../middleware/index.js';

const router = express.Router();

// Database connection
const pool = new Pool({
    connectionString: process.env.DATABASE_URL || 'postgres://postgres:password@localhost:5432/yene_farm'
});

// Validation schemas
const createProductSchema = Joi.object({
    title: Joi.string().min(1).max(255).required(),
    description: Joi.string().max(2000).optional(),
    price: Joi.number().precision(2).positive().required(),
    images: Joi.array().items(Joi.string().uri()).max(10).optional(),
    categoryId: Joi.string().uuid().required(),
    quantityAvailable: Joi.number().integer().min(0).optional(),
    unit: Joi.string().max(20).optional()
});

const updateProductSchema = Joi.object({
    title: Joi.string().min(1).max(255).optional(),
    description: Joi.string().max(2000).optional(),
    price: Joi.number().precision(2).positive().optional(),
    images: Joi.array().items(Joi.string().uri()).max(10).optional(),
    categoryId: Joi.string().uuid().optional(),
    quantityAvailable: Joi.number().integer().min(0).optional(),
    unit: Joi.string().max(20).optional(),
    isAvailable: Joi.boolean().optional()
});

// GET /api/products - Get all products with filtering and pagination
router.get('/', optionalAuth, async (req, res) => {
    try {
        const page = parseInt(req.query.page) || 1;
        const limit = parseInt(req.query.limit) || 20;
        const offset = (page - 1) * limit;
        const search = req.query.search;
        const categoryId = req.query.categoryId;
        const minPrice = req.query.minPrice ? parseFloat(req.query.minPrice) : null;
        const maxPrice = req.query.maxPrice ? parseFloat(req.query.maxPrice) : null;
        const sellerId = req.query.sellerId;
        const sortBy = req.query.sortBy || 'created_at';
        const sortOrder = req.query.sortOrder || 'DESC';

        let query = `
            SELECT p.*, c.name as category_name, u.first_name, u.last_name, u.profile_image as seller_image,
                   (SELECT AVG(rating) FROM reviews WHERE product_id = p.id) as avg_rating,
                   (SELECT COUNT(*) FROM reviews WHERE product_id = p.id) as review_count
            FROM products p
            LEFT JOIN categories c ON p.category_id = c.id
            LEFT JOIN users u ON p.seller_id = u.id
            WHERE p.is_available = true
        `;
        
        const queryParams = [];
        let paramCount = 1;

        if (search) {
            query += ` AND (p.title ILIKE $${paramCount} OR p.description ILIKE $${paramCount})`;
            queryParams.push(`%${search}%`);
            paramCount++;
        }

        if (categoryId) {
            query += ` AND p.category_id = $${paramCount}`;
            queryParams.push(categoryId);
            paramCount++;
        }

        if (minPrice !== null) {
            query += ` AND p.price >= $${paramCount}`;
            queryParams.push(minPrice);
            paramCount++;
        }

        if (maxPrice !== null) {
            query += ` AND p.price <= $${paramCount}`;
            queryParams.push(maxPrice);
            paramCount++;
        }

        if (sellerId) {
            query += ` AND p.seller_id = $${paramCount}`;
            queryParams.push(sellerId);
            paramCount++;
        }

        // Add sorting
        const allowedSortFields = ['created_at', 'price', 'title', 'avg_rating'];
        const sortField = allowedSortFields.includes(sortBy) ? sortBy : 'created_at';
        const order = sortOrder.toUpperCase() === 'ASC' ? 'ASC' : 'DESC';
        query += ` ORDER BY p.${sortField} ${order}`;

        // Add pagination
        query += ` LIMIT $${paramCount} OFFSET $${paramCount + 1}`;
        queryParams.push(limit, offset);

        const result = await pool.query(query, queryParams);

        // Get total count for pagination
        let countQuery = `
            SELECT COUNT(*) FROM products p
            WHERE p.is_available = true
        `;
        const countParams = [];
        let countParamCount = 1;

        if (search) {
            countQuery += ` AND (p.title ILIKE $${countParamCount} OR p.description ILIKE $${countParamCount})`;
            countParams.push(`%${search}%`);
            countParamCount++;
        }

        if (categoryId) {
            countQuery += ` AND p.category_id = $${countParamCount}`;
            countParams.push(categoryId);
            countParamCount++;
        }

        if (minPrice !== null) {
            countQuery += ` AND p.price >= $${countParamCount}`;
            countParams.push(minPrice);
            countParamCount++;
        }

        if (maxPrice !== null) {
            countQuery += ` AND p.price <= $${countParamCount}`;
            countParams.push(maxPrice);
            countParamCount++;
        }

        if (sellerId) {
            countQuery += ` AND p.seller_id = $${countParamCount}`;
            countParams.push(sellerId);
            countParamCount++;
        }

        const countResult = await pool.query(countQuery, countParams);
        const totalCount = parseInt(countResult.rows[0].count);
        const totalPages = Math.ceil(totalCount / limit);

        res.json({
            products: result.rows.map(product => ({
                id: product.id,
                title: product.title,
                description: product.description,
                price: parseFloat(product.price),
                images: product.images || [],
                categoryId: product.category_id,
                categoryName: product.category_name,
                sellerId: product.seller_id,
                sellerName: `${product.first_name} ${product.last_name}`,
                sellerImage: product.seller_image,
                quantityAvailable: product.quantity_available,
                unit: product.unit,
                isAvailable: product.is_available,
                avgRating: product.avg_rating ? parseFloat(product.avg_rating) : null,
                reviewCount: parseInt(product.review_count),
                createdAt: product.created_at,
                updatedAt: product.updated_at
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
        console.error('Get products error:', err);
        res.status(500).json({ error: 'Internal server error' });
    }
});

// GET /api/products/:id - Get single product
router.get('/:id', optionalAuth, async (req, res) => {
    try {
        const { id } = req.params;

        const result = await pool.query(`
            SELECT p.*, c.name as category_name, u.first_name, u.last_name, u.profile_image as seller_image,
                   u.phone as seller_phone, u.email as seller_email,
                   (SELECT AVG(rating) FROM reviews WHERE product_id = p.id) as avg_rating,
                   (SELECT COUNT(*) FROM reviews WHERE product_id = p.id) as review_count
            FROM products p
            LEFT JOIN categories c ON p.category_id = c.id
            LEFT JOIN users u ON p.seller_id = u.id
            WHERE p.id = $1
        `, [id]);

        if (result.rows.length === 0) {
            return res.status(404).json({ error: 'Product not found' });
        }

        const product = result.rows[0];

        res.json({
            id: product.id,
            title: product.title,
            description: product.description,
            price: parseFloat(product.price),
            images: product.images || [],
            categoryId: product.category_id,
            categoryName: product.category_name,
            sellerId: product.seller_id,
            sellerName: `${product.first_name} ${product.last_name}`,
            sellerImage: product.seller_image,
            sellerPhone: product.seller_phone,
            sellerEmail: product.seller_email,
            quantityAvailable: product.quantity_available,
            unit: product.unit,
            isAvailable: product.is_available,
            avgRating: product.avg_rating ? parseFloat(product.avg_rating) : null,
            reviewCount: parseInt(product.review_count),
            createdAt: product.created_at,
            updatedAt: product.updated_at
        });

    } catch (err) {
        console.error('Get product error:', err);
        res.status(500).json({ error: 'Internal server error' });
    }
});

// POST /api/products - Create new product (farmers only)
router.post('/', requireAuth, requireUserType(['farmer']), validateBody(createProductSchema), async (req, res) => {
    try {
        const { title, description, price, images, categoryId, quantityAvailable, unit } = req.body;

        const result = await pool.query(`
            INSERT INTO products (title, description, price, images, category_id, seller_id, quantity_available, unit)
            VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
            RETURNING *
        `, [title, description, price, images || [], categoryId, req.user.id, quantityAvailable || 0, unit || 'kg']);

        const product = result.rows[0];

        res.status(201).json({
            message: 'Product created successfully',
            product: {
                id: product.id,
                title: product.title,
                description: product.description,
                price: parseFloat(product.price),
                images: product.images || [],
                categoryId: product.category_id,
                sellerId: product.seller_id,
                quantityAvailable: product.quantity_available,
                unit: product.unit,
                isAvailable: product.is_available,
                createdAt: product.created_at
            }
        });

    } catch (err) {
        console.error('Create product error:', err);
        res.status(500).json({ error: 'Internal server error' });
    }
});

// PUT /api/products/:id - Update product (seller or admin only)
router.put('/:id', requireAuth, validateBody(updateProductSchema), async (req, res) => {
    try {
        const { id } = req.params;
        const updates = req.body;

        // Check if product exists and user has permission
        const productResult = await pool.query(
            'SELECT seller_id FROM products WHERE id = $1',
            [id]
        );

        if (productResult.rows.length === 0) {
            return res.status(404).json({ error: 'Product not found' });
        }

        const product = productResult.rows[0];
        
        // Check if user is the seller or admin
        if (product.seller_id !== req.user.id && req.user.userType !== 'admin') {
            return res.status(403).json({ error: 'Permission denied' });
        }

        // Build update query
        const updateFields = [];
        const values = [];
        let paramCount = 1;

        Object.keys(updates).forEach(key => {
            if (updates[key] !== undefined) {
                const dbKey = key === 'categoryId' ? 'category_id' : 
                             key === 'quantityAvailable' ? 'quantity_available' :
                             key === 'isAvailable' ? 'is_available' : key;
                updateFields.push(`${dbKey} = $${paramCount++}`);
                values.push(updates[key]);
            }
        });

        if (updateFields.length === 0) {
            return res.status(400).json({ error: 'No fields to update' });
        }

        updateFields.push(`updated_at = now()`);
        values.push(id);

        const query = `
            UPDATE products 
            SET ${updateFields.join(', ')} 
            WHERE id = $${paramCount} 
            RETURNING *
        `;

        const result = await pool.query(query, values);
        const updatedProduct = result.rows[0];

        res.json({
            message: 'Product updated successfully',
            product: {
                id: updatedProduct.id,
                title: updatedProduct.title,
                description: updatedProduct.description,
                price: parseFloat(updatedProduct.price),
                images: updatedProduct.images || [],
                categoryId: updatedProduct.category_id,
                sellerId: updatedProduct.seller_id,
                quantityAvailable: updatedProduct.quantity_available,
                unit: updatedProduct.unit,
                isAvailable: updatedProduct.is_available,
                updatedAt: updatedProduct.updated_at
            }
        });

    } catch (err) {
        console.error('Update product error:', err);
        res.status(500).json({ error: 'Internal server error' });
    }
});

// DELETE /api/products/:id - Delete product (seller or admin only)
router.delete('/:id', requireAuth, async (req, res) => {
    try {
        const { id } = req.params;

        // Check if product exists and user has permission
        const productResult = await pool.query(
            'SELECT seller_id FROM products WHERE id = $1',
            [id]
        );

        if (productResult.rows.length === 0) {
            return res.status(404).json({ error: 'Product not found' });
        }

        const product = productResult.rows[0];
        
        // Check if user is the seller or admin
        if (product.seller_id !== req.user.id && req.user.userType !== 'admin') {
            return res.status(403).json({ error: 'Permission denied' });
        }

        await pool.query('DELETE FROM products WHERE id = $1', [id]);

        res.json({ message: 'Product deleted successfully' });

    } catch (err) {
        console.error('Delete product error:', err);
        res.status(500).json({ error: 'Internal server error' });
    }
});

// GET /api/products/my-products - Get current user's products (farmers only)
router.get('/my-products', requireAuth, requireUserType(['farmer']), async (req, res) => {
    try {
        const page = parseInt(req.query.page) || 1;
        const limit = parseInt(req.query.limit) || 20;
        const offset = (page - 1) * limit;

        const result = await pool.query(`
            SELECT p.*, c.name as category_name,
                   (SELECT AVG(rating) FROM reviews WHERE product_id = p.id) as avg_rating,
                   (SELECT COUNT(*) FROM reviews WHERE product_id = p.id) as review_count
            FROM products p
            LEFT JOIN categories c ON p.category_id = c.id
            WHERE p.seller_id = $1
            ORDER BY p.created_at DESC
            LIMIT $2 OFFSET $3
        `, [req.user.id, limit, offset]);

        const countResult = await pool.query(
            'SELECT COUNT(*) FROM products WHERE seller_id = $1',
            [req.user.id]
        );

        const totalCount = parseInt(countResult.rows[0].count);
        const totalPages = Math.ceil(totalCount / limit);

        res.json({
            products: result.rows.map(product => ({
                id: product.id,
                title: product.title,
                description: product.description,
                price: parseFloat(product.price),
                images: product.images || [],
                categoryId: product.category_id,
                categoryName: product.category_name,
                quantityAvailable: product.quantity_available,
                unit: product.unit,
                isAvailable: product.is_available,
                avgRating: product.avg_rating ? parseFloat(product.avg_rating) : null,
                reviewCount: parseInt(product.review_count),
                createdAt: product.created_at,
                updatedAt: product.updated_at
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
        console.error('Get my products error:', err);
        res.status(500).json({ error: 'Internal server error' });
    }
});

export default router;