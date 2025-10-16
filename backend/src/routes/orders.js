const express = require('express');
const router = express.Router();
const supabase = require('../lib/supabaseClient');
const Joi = require('joi');
const { validateBody, requireAuth } = require('../middleware');

const orderSchema = Joi.object({
  user_id: Joi.string().uuid().required(),
  items: Joi.array().items(
    Joi.object({ product_id: Joi.string().uuid().required(), quantity: Joi.number().integer().min(1).required(), price: Joi.number().precision(2).required() })
  ).min(1).required(),
  total: Joi.number().precision(2).positive().required(),
  address: Joi.object().optional(),
  metadata: Joi.object().optional(),
});

// Create an order (must be authenticated)
router.post('/', requireAuth, validateBody(orderSchema), async (req, res) => {
  try {
    const payload = req.body;
    // ensure user cannot create order for another user
    if (req.user && req.user.id !== payload.user_id) return res.status(403).json({ error: 'forbidden' });

    const { data, error } = await supabase.from('orders').insert([payload]).select().single();
    if (error) return res.status(500).json({ error: 'db_error', details: error });
    res.status(201).json(data);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get orders for a user (authenticated)
router.get('/:userId', requireAuth, async (req, res) => {
  try {
    const { userId } = req.params;
    if (req.user && req.user.id !== userId) return res.status(403).json({ error: 'forbidden' });
    const { data, error } = await supabase.from('orders').select('*').eq('user_id', userId).order('created_at', { ascending: false });
    if (error) return res.status(500).json({ error: 'db_error', details: error });
    res.json(data);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
