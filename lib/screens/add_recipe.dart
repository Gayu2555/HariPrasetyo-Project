import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:unicons/unicons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:recipe_app/services/auth_storage.dart';
import 'dart:async';
// Menghapus AuthManager dan menggunakan AuthStorage yang sudah ada
// class AuthManager { ... } // Tidak perlu lagi

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

  bool _isLoading = false;

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
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        // Verifikasi file exists
        final file = File(image.path);
        if (await file.exists()) {
          setState(() {
            _mainImage = file;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Foto berhasil dipilih'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 1),
              ),
            );
          }
        } else {
          throw Exception('File tidak ditemukan');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memilih foto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      debugPrint('Error picking image: $e');
    }
  }

  Future<void> _pickStepImage(int index) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        final file = File(image.path);
        if (await file.exists()) {
          setState(() {
            _stepItems[index].image = file;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Foto langkah ${index + 1} berhasil dipilih'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 1),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memilih foto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      debugPrint('Error picking step image: $e');
    }
  }

  // =================================================================
  // PERBAIKAN 2: DIALOG PILIHAN KAMERA ATAU GALERI
  // =================================================================
  Future<void> _showImageSourceDialog(Function(ImageSource) onSelected) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pilih Sumber Foto'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.blue),
                title: const Text('Kamera'),
                onTap: () {
                  Navigator.pop(context);
                  onSelected(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.green),
                title: const Text('Galeri'),
                onTap: () {
                  Navigator.pop(context);
                  onSelected(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickMainImageWithDialog() async {
    await _showImageSourceDialog((source) async {
      try {
        final XFile? image = await _picker.pickImage(
          source: source,
          maxWidth: 1920,
          maxHeight: 1080,
          imageQuality: 85,
        );

        if (image != null) {
          final file = File(image.path);
          if (await file.exists()) {
            setState(() {
              _mainImage = file;
            });

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Foto berhasil dipilih'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 1),
                ),
              );
            }
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal memilih foto: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
        debugPrint('Error: $e');
      }
    });
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

  int _extractMinutes(String timeString) {
    final regex = RegExp(r'(\d+)');
    final match = regex.firstMatch(timeString);
    return match != null ? int.parse(match.group(0)!) : 0;
  }

  Future<void> _saveRecipe() async {
    if (_formKey.currentState!.validate()) {
      if (_mainImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Harap tambahkan foto makanan')),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        final ingredients = _ingredientControllers
            .map((c) => c.text)
            .where((text) => text.isNotEmpty)
            .toList();

        final steps = _stepItems.map((step) {
          return {
            'description': step.controller.text,
            'image': step.image?.path,
          };
        }).toList();

        final servings = int.tryParse(_servingsController.text) ?? 1;
        final prepTimeInMinutes = _extractMinutes(_prepTimeController.text);
        final cookTimeInMinutes = _extractMinutes(_cookTimeController.text);

        final response = await _createRecipe(
          title: _titleController.text,
          description: _descriptionController.text,
          category: _selectedCategory,
          difficulty: _selectedDifficulty,
          servings: servings,
          prepTime: prepTimeInMinutes,
          cookTime: cookTimeInMinutes,
          mainImage: _mainImage!,
          ingredients: ingredients,
          steps: steps,
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Resep berhasil disimpan!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context, response);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan resep: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  // =================================================================
  // PERBAIKAN 3: VALIDASI FILE SEBELUM UPLOAD
  // =================================================================
  Future<Map<String, dynamic>> _createRecipe({
    required String title,
    required String description,
    required String category,
    required String difficulty,
    required int servings,
    required int prepTime,
    required int cookTime,
    required File mainImage,
    required List<String> ingredients,
    required List<Map<String, dynamic>> steps,
  }) async {
    const String baseUrl = 'https://api.gayuyunma.my.id';

    try {
      // Validasi file exists
      if (!await mainImage.exists()) {
        throw Exception('File gambar utama tidak ditemukan');
      }

      // Validasi ukuran file (max 10MB)
      final fileSize = await mainImage.length();
      if (fileSize > 10 * 1024 * 1024) {
        throw Exception('Ukuran file terlalu besar (max 10MB)');
      }

      // Validasi data tidak kosong
      if (title.trim().isEmpty) {
        throw Exception('Judul tidak boleh kosong');
      }

      final uri = Uri.parse('$baseUrl/recipes');
      final request = http.MultipartRequest('POST', uri);

      // Get token
      final token = await AuthStorage.getToken();

      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      } else {
        throw Exception('Token tidak ditemukan. Silakan login kembali.');
      }

      // PERBAIKAN: Pastikan Content-Type header tidak di-override
      // Biarkan http package yang handle Content-Type untuk multipart

      // Add text fields - PASTIKAN DATA VALID
      request.fields['title'] = title.trim();
      request.fields['description'] = description.trim();
      request.fields['category'] = category;
      request.fields['difficulty'] = difficulty;
      request.fields['servings'] = servings.toString();
      request.fields['prepTime'] = prepTime.toString();
      request.fields['cookTime'] = cookTime.toString();

      // PERBAIKAN: Format ingredients sebagai array JSON yang benar
      request.fields['ingredients'] = jsonEncode(ingredients);

      // Debug: Print semua fields
      debugPrint('=== REQUEST FIELDS ===');
      request.fields.forEach((key, value) {
        debugPrint('$key: $value');
      });

      // Add main image
      try {
        final mainImageMimeType =
            lookupMimeType(mainImage.path) ?? 'image/jpeg';
        debugPrint('Main Image MIME Type: $mainImageMimeType');
        debugPrint('Main Image Path: ${mainImage.path}');

        final mainImageFile = await http.MultipartFile.fromPath(
          'mainImage',
          mainImage.path,
          contentType: MediaType.parse(mainImageMimeType),
        );
        request.files.add(mainImageFile);
        debugPrint('Main image added successfully');
      } catch (e) {
        debugPrint('Error adding main image: $e');
        throw Exception('Gagal menambahkan gambar utama: $e');
      }

      // Add steps with proper format
      for (int i = 0; i < steps.length; i++) {
        final stepDescription = steps[i]['description'] as String;

        // PERBAIKAN: Format steps sesuai ekspektasi backend
        request.fields['steps[$i][description]'] = stepDescription.trim();
        request.fields['steps[$i][order]'] = (i + 1).toString();

        debugPrint('Step $i description: $stepDescription');

        // Add step image if exists
        if (steps[i]['image'] != null) {
          final stepImagePath = steps[i]['image'] as String;
          final stepImageFile = File(stepImagePath);

          if (await stepImageFile.exists()) {
            try {
              final stepImageMimeType =
                  lookupMimeType(stepImagePath) ?? 'image/jpeg';
              final stepImage = await http.MultipartFile.fromPath(
                'steps[$i][image]',
                stepImagePath,
                contentType: MediaType.parse(stepImageMimeType),
              );
              request.files.add(stepImage);
              debugPrint('Step $i image added: $stepImagePath');
            } catch (e) {
              debugPrint('Error adding step $i image: $e');
              // Continue tanpa gambar step jika error
            }
          }
        }
      }

      debugPrint('=== SENDING REQUEST ===');
      debugPrint('URL: $uri');
      debugPrint('Total fields: ${request.fields.length}');
      debugPrint('Total files: ${request.files.length}');
      debugPrint('Headers: ${request.headers}');

      // Send request dengan timeout
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw Exception('Request timeout. Periksa koneksi internet Anda.');
        },
      );

      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('=== RESPONSE ===');
      debugPrint('Status: ${response.statusCode}');
      debugPrint('Body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        try {
          return jsonDecode(response.body);
        } catch (e) {
          debugPrint('Error parsing response: $e');
          throw Exception('Gagal membaca response dari server');
        }
      } else if (response.statusCode == 401) {
        throw Exception(
            'Token tidak valid atau kadaluarsa. Silakan login kembali.');
      } else if (response.statusCode == 403) {
        throw Exception('Anda tidak memiliki izin untuk menambah resep');
      } else if (response.statusCode == 400) {
        // Parse error message dari backend
        try {
          final errorData = jsonDecode(response.body);
          final errorMessage = errorData['message'];
          if (errorMessage is List) {
            throw Exception('Validasi gagal:\n${errorMessage.join('\n')}');
          } else {
            throw Exception('Data tidak valid: ${errorData['message']}');
          }
        } catch (e) {
          throw Exception('Data tidak valid: ${response.body}');
        }
      } else {
        throw Exception(
            'Server error (${response.statusCode}): ${response.body}');
      }
    } on SocketException {
      throw Exception('Tidak ada koneksi internet. Periksa koneksi Anda.');
    } on TimeoutException {
      throw Exception('Request timeout. Coba lagi.');
    } catch (e) {
      debugPrint('Error in _createRecipe: $e');
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Resep'),
        leading: IconButton(
          icon: const Icon(UniconsLine.arrow_left),
          onPressed: _isLoading ? null : () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveRecipe,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
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
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Foto Makanan'),
                  _buildMainImagePicker(),
                  SizedBox(height: 3.0.h),
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
                          hint: '30',
                          icon: UniconsLine.clock,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.0.h),
                  _buildTextField(
                    controller: _cookTimeController,
                    label: 'Waktu Memasak (menit)',
                    hint: '45',
                    icon: UniconsLine.fire,
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 3.0.h),
                  _buildSectionTitle('Bahan-Bahan'),
                  _buildIngredientsList(),
                  SizedBox(height: 1.0.h),
                  _buildAddButton('Tambah Bahan', _addIngredient),
                  SizedBox(height: 3.0.h),
                  _buildSectionTitle('Langkah-Langkah'),
                  _buildStepsList(),
                  SizedBox(height: 1.0.h),
                  _buildAddButton('Tambah Langkah', _addStep),
                  SizedBox(height: 4.0.h),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveRecipe,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
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
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Menyimpan resep...'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
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
      onTap: _isLoading ? null : _pickMainImageWithDialog,
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
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error,
                                  color: Colors.red, size: 50),
                              const SizedBox(height: 8),
                              Text('Error: $error'),
                            ],
                          ),
                        );
                      },
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: CircleAvatar(
                        backgroundColor: Colors.black54,
                        child: IconButton(
                          icon: const Icon(UniconsLine.camera,
                              color: Colors.white, size: 20),
                          onPressed:
                              _isLoading ? null : _pickMainImageWithDialog,
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
      enabled: !_isLoading,
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
      onChanged: _isLoading ? null : onChanged,
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
                  enabled: !_isLoading,
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
                  onPressed: _isLoading ? null : () => _removeIngredient(index),
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
                        onPressed: _isLoading ? null : () => _removeStep(index),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _stepItems[index].controller,
                  maxLines: 3,
                  enabled: !_isLoading,
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
                  onTap: _isLoading ? null : () => _pickStepImage(index),
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
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Center(
                                      child:
                                          Icon(Icons.error, color: Colors.red),
                                    );
                                  },
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
                                      onPressed: _isLoading
                                          ? null
                                          : () => _pickStepImage(index),
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
      onPressed: _isLoading ? null : onPressed,
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

class StepItem {
  TextEditingController controller;
  File? image;

  StepItem({required this.controller, this.image});
}
