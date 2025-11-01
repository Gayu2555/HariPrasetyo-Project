import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:unicons/unicons.dart';
import 'package:image_picker/image_picker.dart';

class AddRecipeScreen extends StatefulWidget {
  const AddRecipeScreen({Key? key}) : super(key: key);

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _servingsController = TextEditingController();
  final _cookTimeController = TextEditingController();
  final _prepTimeController = TextEditingController();

  File? _mainImage;
  final ImagePicker _picker = ImagePicker();

  // List untuk ingredients dan steps
  List<TextEditingController> _ingredientControllers = [
    TextEditingController()
  ];
  List<StepItem> _stepItems = [StepItem(controller: TextEditingController())];

  String _selectedCategory = 'Sarapan';
  String _selectedDifficulty = 'Mudah';

  final List<String> _categories = [
    'Sarapan',
    'Makan Siang',
    'Makan Malam',
    'Dessert',
    'Cemilan',
    'Minuman',
  ];

  final List<String> _difficulties = ['Mudah', 'Sedang', 'Sulit'];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _servingsController.dispose();
    _cookTimeController.dispose();
    _prepTimeController.dispose();
    for (var controller in _ingredientControllers) {
      controller.dispose();
    }
    for (var step in _stepItems) {
      step.controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickMainImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _mainImage = File(image.path);
      });
    }
  }

  Future<void> _pickStepImage(int index) async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _stepItems[index].image = File(image.path);
      });
    }
  }

  void _addIngredient() {
    setState(() {
      _ingredientControllers.add(TextEditingController());
    });
  }

  void _removeIngredient(int index) {
    if (_ingredientControllers.length > 1) {
      setState(() {
        _ingredientControllers[index].dispose();
        _ingredientControllers.removeAt(index);
      });
    }
  }

  void _addStep() {
    setState(() {
      _stepItems.add(StepItem(controller: TextEditingController()));
    });
  }

  void _removeStep(int index) {
    if (_stepItems.length > 1) {
      setState(() {
        _stepItems[index].controller.dispose();
        _stepItems.removeAt(index);
      });
    }
  }

  void _saveRecipe() {
    if (_formKey.currentState!.validate()) {
      if (_mainImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Harap tambahkan foto makanan')),
        );
        return;
      }

      // Simpan resep ke database atau provider
      // Contoh data yang dikumpulkan:
      final recipeData = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'category': _selectedCategory,
        'difficulty': _selectedDifficulty,
        'servings': _servingsController.text,
        'prepTime': _prepTimeController.text,
        'cookTime': _cookTimeController.text,
        'mainImage': _mainImage!.path,
        'ingredients': _ingredientControllers
            .map((c) => c.text)
            .where((text) => text.isNotEmpty)
            .toList(),
        'steps': _stepItems.map((step) {
          return {
            'description': step.controller.text,
            'image': step.image?.path,
          };
        }).toList(),
      };

      print('Recipe Data: $recipeData');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Resep berhasil disimpan!')),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Resep'),
        leading: IconButton(
          icon: const Icon(UniconsLine.arrow_left),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _saveRecipe,
            child: Text(
              'Simpan',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main Image Section
              _buildSectionTitle('Foto Makanan'),
              _buildMainImagePicker(),
              SizedBox(height: 3.0.h),

              // Basic Info Section
              _buildSectionTitle('Informasi Dasar'),
              _buildTextField(
                controller: _titleController,
                label: 'Nama Resep',
                hint: 'Contoh: Nasi Goreng Spesial',
                icon: UniconsLine.restaurant,
              ),
              SizedBox(height: 2.0.h),
              _buildTextField(
                controller: _descriptionController,
                label: 'Deskripsi',
                hint: 'Ceritakan tentang resep ini...',
                icon: UniconsLine.align_left,
                maxLines: 3,
              ),
              SizedBox(height: 2.0.h),

              // Category and Difficulty
              Row(
                children: [
                  Expanded(
                    child: _buildDropdown(
                      label: 'Kategori',
                      value: _selectedCategory,
                      items: _categories,
                      onChanged: (value) {
                        setState(() => _selectedCategory = value!);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDropdown(
                      label: 'Tingkat Kesulitan',
                      value: _selectedDifficulty,
                      items: _difficulties,
                      onChanged: (value) {
                        setState(() => _selectedDifficulty = value!);
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.0.h),

              // Time and Servings
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _servingsController,
                      label: 'Porsi',
                      hint: '4',
                      icon: UniconsLine.user,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: _prepTimeController,
                      label: 'Waktu Persiapan',
                      hint: '30 menit',
                      icon: UniconsLine.clock,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.0.h),
              _buildTextField(
                controller: _cookTimeController,
                label: 'Waktu Memasak',
                hint: '45 menit',
                icon: UniconsLine.fire,
              ),
              SizedBox(height: 3.0.h),

              // Ingredients Section
              _buildSectionTitle('Bahan-Bahan'),
              _buildIngredientsList(),
              SizedBox(height: 1.0.h),
              _buildAddButton('Tambah Bahan', _addIngredient),
              SizedBox(height: 3.0.h),

              // Steps Section
              _buildSectionTitle('Langkah-Langkah'),
              _buildStepsList(),
              SizedBox(height: 1.0.h),
              _buildAddButton('Tambah Langkah', _addStep),
              SizedBox(height: 4.0.h),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveRecipe,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Simpan Resep',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 2.0.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildMainImagePicker() {
    return GestureDetector(
      onTap: _pickMainImage,
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300, width: 2),
        ),
        child: _mainImage != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    Image.file(
                      _mainImage!,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: CircleAvatar(
                        backgroundColor: Colors.black54,
                        child: IconButton(
                          icon: const Icon(UniconsLine.camera,
                              color: Colors.white, size: 20),
                          onPressed: _pickMainImage,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    UniconsLine.image_plus,
                    size: 50,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Ketuk untuk menambah foto',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13.sp,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Field tidak boleh kosong';
        }
        return null;
      },
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildIngredientsList() {
    return Column(
      children: List.generate(_ingredientControllers.length, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _ingredientControllers[index],
                  decoration: InputDecoration(
                    hintText: 'Contoh: 500 gram ayam fillet',
                    prefixIcon: const Icon(UniconsLine.check_circle),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Bahan tidak boleh kosong';
                    }
                    return null;
                  },
                ),
              ),
              if (_ingredientControllers.length > 1)
                IconButton(
                  icon: const Icon(UniconsLine.trash_alt, color: Colors.red),
                  onPressed: () => _removeIngredient(index),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStepsList() {
    return Column(
      children: List.generate(_stepItems.length, (index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 16.0),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (_stepItems.length > 1)
                      IconButton(
                        icon: const Icon(UniconsLine.trash_alt,
                            color: Colors.red),
                        onPressed: () => _removeStep(index),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _stepItems[index].controller,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Jelaskan langkah ini...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Langkah tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => _pickStepImage(index),
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: Colors.grey.shade300, width: 1.5),
                    ),
                    child: _stepItems[index].image != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Stack(
                              children: [
                                Image.file(
                                  _stepItems[index].image!,
                                  width: double.infinity,
                                  height: 150,
                                  fit: BoxFit.cover,
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: CircleAvatar(
                                    radius: 18,
                                    backgroundColor: Colors.black54,
                                    child: IconButton(
                                      icon: const Icon(
                                        UniconsLine.camera,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                      onPressed: () => _pickStepImage(index),
                                      padding: EdgeInsets.zero,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                UniconsLine.image_plus,
                                size: 40,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tambah foto (opsional)',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildAddButton(String text, VoidCallback onPressed) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Icon(UniconsLine.plus),
      label: Text(text),
      style: OutlinedButton.styleFrom(
        foregroundColor: Theme.of(context).primaryColor,
        side: BorderSide(color: Theme.of(context).primaryColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
    );
  }
}

// Helper class untuk menyimpan data step
class StepItem {
  TextEditingController controller;
  File? image;

  StepItem({required this.controller, this.image});
}
