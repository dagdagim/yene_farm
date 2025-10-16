import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:yene_farm/models/product_model.dart';
import 'package:yene_farm/providers/marketplace_provider.dart';
import 'package:yene_farm/providers/auth_provider.dart';
import 'package:yene_farm/providers/language_provider.dart';
import 'package:yene_farm/utils/colors.dart';
import 'package:yene_farm/utils/constants.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _quantityCtrl = TextEditingController();
  final _unitCtrl = TextEditingController(text: 'kg');
  final _descriptionCtrl = TextEditingController();
  String _category = 'Cereals';
  DateTime? _harvestDate;
  final List<XFile> _images = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _quantityCtrl.dispose();
    _unitCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
    if (picked != null) {
      setState(() => _images.add(picked));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final marketplace = Provider.of<MarketplaceProvider>(context, listen: false);

    final product = ProductModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      farmerId: auth.currentUser?.id ?? 'unknown',
      farmerName: auth.currentUser?.name ?? 'Farmer',
      name: _nameCtrl.text.trim(),
      category: _category,
      price: double.tryParse(_priceCtrl.text.trim()) ?? 0.0,
      quantity: double.tryParse(_quantityCtrl.text.trim()) ?? 0.0,
      unit: _unitCtrl.text.trim(),
      images: _images.map((e) => e.path).toList(),
      description: _descriptionCtrl.text.trim(),
      harvestDate: _harvestDate ?? DateTime.now(),
      location: auth.currentUser?.location ?? '',
      isOrganic: false,
      farmerRating: auth.currentUser?.rating ?? 0.0,
      createdAt: DateTime.now(),
    );

    await marketplace.addProduct(product);

    setState(() => _isLoading = false);
    Navigator.of(context).pop();
  }

  Future<void> _pickHarvestDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now,
    );
    if (picked != null) setState(() => _harvestDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(languageProvider.currentLanguage == 'am' ? 'ምርት ይጨምሩ' : 'Add Product'),
        backgroundColor: YeneFarmColors.primaryGreen,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Product name'),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _category,
                items: const [
                  DropdownMenuItem(value: 'Cereals', child: Text('Cereals')),
                  DropdownMenuItem(value: 'Coffee', child: Text('Coffee')),
                  DropdownMenuItem(value: 'Vegetables', child: Text('Vegetables')),
                  DropdownMenuItem(value: 'Fruits', child: Text('Fruits')),
                ],
                onChanged: (v) => setState(() => _category = v ?? _category),
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceCtrl,
                      decoration: const InputDecoration(labelText: 'Price'),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _quantityCtrl,
                      decoration: const InputDecoration(labelText: 'Quantity'),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _unitCtrl,
                decoration: const InputDecoration(labelText: 'Unit (e.g., kg)'),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _pickHarvestDate,
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Harvest date'),
                  child: Text(_harvestDate == null ? 'Select date' : _harvestDate!.toLocal().toIso8601String().split('T').first),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionCtrl,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  for (final img in _images)
                    Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Image.file(File(img.path), width: 80, height: 80, fit: BoxFit.cover),
                        Positioned(
                          right: 0,
                          child: GestureDetector(
                            onTap: () => setState(() => _images.remove(img)),
                            child: const CircleAvatar(radius: 10, backgroundColor: Colors.black54, child: Icon(Icons.close, size: 12, color: Colors.white)),
                          ),
                        )
                      ],
                    ),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: YeneFarmColors.border),
                      ),
                      child: const Icon(Icons.add_a_photo_rounded, color: YeneFarmColors.primaryGreen),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Add product'),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}