const express = require('express');
const router = express.Router();
const supabase = require('../lib/supabaseClient');
const Joi = require('joi');
const { validateBody, requireAuth, requireAdmin } = require('../middleware');

const categorySchema = Joi.object({
  name: Joi.string().min(1).max(255).required(),
  description: Joi.string().allow('', null).max(2000),
  metadata: Joi.object().optional(),
});

// List categories
router.get('/', async (req, res) => {
  try {
    const { data, error } = await supabase.from('categories').select('*').order('created_at', { ascending: false });
    if (error) return res.status(500).json({ error: 'db_error', details: error });
    res.json({ data });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Create category (admin)
router.post('/', requireAdmin, validateBody(categorySchema), async (req, res) => {
  try {
    const { data, error } = await supabase.from('categories').insert([req.body]).select().single();
    if (error) return res.status(500).json({ error: 'db_error', details: error });
    res.status(201).json(data);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Update category (admin)
router.put('/:id', requireAdmin, validateBody(categorySchema), async (req, res) => {
  try {
    const { id } = req.params;
    const { data, error } = await supabase.from('categories').update(req.body).eq('id', id).select().single();
    if (error) return res.status(500).json({ error: 'db_error', details: error });
    res.json(data);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Delete category (admin)
router.delete('/:id', requireAdmin, async (req, res) => {
  try {
    const { id } = req.params;
    const { error } = await supabase.from('categories').delete().eq('id', id);
    if (error) return res.status(500).json({ error: 'db_error', details: error });
    res.status(204).send();
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
