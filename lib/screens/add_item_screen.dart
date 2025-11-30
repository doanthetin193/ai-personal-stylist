import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/wardrobe_provider.dart';
import '../models/clothing_item.dart';
import '../services/gemini_service.dart';
import '../utils/theme.dart';
import '../widgets/loading_widgets.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final ImagePicker _picker = ImagePicker();
  GeminiService? _geminiService;
  XFile? _pickedFile;
  Uint8List? _imageBytes;
  bool _isAnalyzing = false;
  bool _isSaving = false;
  Map<String, dynamic>? _analysisResult;
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _geminiService ??= context.read<GeminiService>();
  }

  // Editable fields
  ClothingType? _selectedType;
  String? _selectedColor;
  String? _selectedMaterial;
  List<ClothingStyle> _selectedStyles = [];
  List<Season> _selectedSeasons = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Thêm đồ mới'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.accentColor.withValues(alpha: 0.1),
                AppTheme.primaryColor.withValues(alpha: 0.05),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFECFDF5),  // Cyan 50
              AppTheme.backgroundColor,
            ],
            stops: [0.0, 0.2],
          ),
        ),
        child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image picker
            _buildImageSection(),
            
            const SizedBox(height: 24),
            
            // AI Analysis result
            if (_isAnalyzing) _buildAnalyzingState(),
            
            if (_analysisResult != null && !_isAnalyzing) ...[
              _buildAnalysisResult(),
              const SizedBox(height: 24),
              _buildEditableFields(),
              const SizedBox(height: 32),
              _buildSaveButton(),
            ],
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return GestureDetector(
      onTap: _imageBytes == null ? _showImageSourceDialog : null,
      child: Container(
        height: 300,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _imageBytes == null 
                ? AppTheme.primaryColor.withValues(alpha: 0.3)
                : Colors.transparent,
            width: 2,
            style: BorderStyle.solid,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: _imageBytes == null
            ? _buildImagePlaceholder()
            : _buildImagePreview(),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.add_a_photo,
            size: 48,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Chụp hoặc chọn ảnh',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'AI sẽ tự động phân tích',
          style: TextStyle(
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildImagePreview() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.memory(
            _imageBytes!,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 12,
          right: 12,
          child: Row(
            children: [
              _buildImageButton(
                icon: Icons.refresh,
                onTap: _showImageSourceDialog,
              ),
              const SizedBox(width: 8),
              _buildImageButton(
                icon: Icons.close,
                onTap: () {
                  setState(() {
                    _pickedFile = null;
                    _imageBytes = null;
                    _analysisResult = null;
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildAnalyzingState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: AppDecorations.cardDecoration,
      child: const AIAnalyzingAnimation(
        message: 'AI đang phân tích quần áo...',
      ),
    );
  }

  Widget _buildAnalysisResult() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.successColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.successColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: AppTheme.successColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Phân tích thành công!',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Kiểm tra và chỉnh sửa nếu cần',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Type
        _buildFieldLabel('Loại đồ'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ClothingType.values.map((type) {
            final isSelected = _selectedType == type;
            return GestureDetector(
              onTap: () => setState(() => _selectedType = type),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppTheme.primaryColor 
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected 
                        ? AppTheme.primaryColor 
                        : Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  type.displayName,
                  style: TextStyle(
                    color: isSelected 
                        ? Colors.white 
                        : AppTheme.textPrimary,
                    fontWeight: isSelected 
                        ? FontWeight.w600 
                        : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 20),

        // Color
        _buildFieldLabel('Màu sắc'),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: TextField(
            decoration: InputDecoration(
              hintText: _selectedColor ?? 'Nhập màu (VD: blue, red, black)',
              border: InputBorder.none,
            ),
            onChanged: (value) => _selectedColor = value,
            controller: TextEditingController(text: _selectedColor),
          ),
        ),

        const SizedBox(height: 20),

        // Style
        _buildFieldLabel('Phong cách'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ClothingStyle.values.map((style) {
            final isSelected = _selectedStyles.contains(style);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedStyles.remove(style);
                  } else {
                    _selectedStyles.add(style);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppTheme.accentColor.withValues(alpha: 0.2) 
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected 
                        ? AppTheme.accentColor 
                        : Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  style.displayName,
                  style: TextStyle(
                    color: isSelected 
                        ? AppTheme.accentColor 
                        : AppTheme.textPrimary,
                    fontWeight: isSelected 
                        ? FontWeight.w600 
                        : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 20),

        // Season
        _buildFieldLabel('Mùa phù hợp'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: Season.values.map((season) {
            final isSelected = _selectedSeasons.contains(season);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedSeasons.remove(season);
                  } else {
                    _selectedSeasons.add(season);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppTheme.warningColor.withValues(alpha: 0.2) 
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected 
                        ? AppTheme.warningColor 
                        : Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  season.displayName,
                  style: TextStyle(
                    color: isSelected 
                        ? AppTheme.warningColor 
                        : AppTheme.textPrimary,
                    fontWeight: isSelected 
                        ? FontWeight.w600 
                        : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: (_canSave && !_isSaving) ? _saveItem : null,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: _isSaving
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text('Đang lưu...', style: TextStyle(fontSize: 16)),
                ],
              )
            : const Text(
                'Lưu vào tủ đồ',
                style: TextStyle(fontSize: 16),
              ),
      ),
    );
  }

  bool get _canSave {
    return _imageBytes != null &&
        _selectedType != null &&
        _selectedColor != null &&
        _selectedColor!.isNotEmpty &&
        _selectedStyles.isNotEmpty &&
        _selectedSeasons.isNotEmpty;
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Chọn nguồn ảnh',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildSourceOption(
                    icon: Icons.camera_alt,
                    label: 'Chụp ảnh',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSourceOption(
                    icon: Icons.photo_library,
                    label: 'Thư viện',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: AppTheme.primaryColor),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _pickedFile = pickedFile;
          _imageBytes = bytes;
          _analysisResult = null;
        });
        await _analyzeImage();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }

  Future<void> _analyzeImage() async {
    if (_imageBytes == null) return;

    setState(() => _isAnalyzing = true);

    try {
      // Gọi Gemini AI phân tích ảnh thật
      _analysisResult = await _geminiService?.analyzeClothingImageBytes(_imageBytes!);
      
      if (_analysisResult != null) {
        // Set editable fields from AI analysis
        _selectedType = ClothingType.fromString(_analysisResult!['type'] ?? 'other');
        _selectedColor = _analysisResult!['color'] ?? 'unknown';
        _selectedMaterial = _analysisResult!['material'];
        
        if (_analysisResult!['styles'] != null) {
          _selectedStyles = (_analysisResult!['styles'] as List)
              .map((s) => ClothingStyle.fromString(s.toString()))
              .toList();
        } else {
          _selectedStyles = [ClothingStyle.casual];
        }
        
        if (_analysisResult!['seasons'] != null) {
          _selectedSeasons = (_analysisResult!['seasons'] as List)
              .map((s) => Season.fromString(s.toString()))
              .toList();
        } else {
          _selectedSeasons = [Season.summer];
        }
      } else {
        // Fallback nếu AI không phân tích được
        _selectedType = ClothingType.other;
        _selectedColor = 'unknown';
        _selectedStyles = [ClothingStyle.casual];
        _selectedSeasons = [Season.summer];
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('AI không thể phân tích, vui lòng chọn thủ công'),
              backgroundColor: AppTheme.warningColor,
            ),
          );
        }
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi phân tích: $e')),
        );
      }
      // Set defaults on error
      _selectedType = ClothingType.other;
      _selectedColor = 'unknown';
      _selectedStyles = [ClothingStyle.casual];
      _selectedSeasons = [Season.summer];
    } finally {
      if (mounted) {
        setState(() => _isAnalyzing = false);
      }
    }
  }

  Future<void> _saveItem() async {
    if (_imageBytes == null || _pickedFile == null || !_canSave) return;

    setState(() => _isSaving = true);

    try {
      final wardrobeProvider = context.read<WardrobeProvider>();
      
      // Create item with selected data
      ClothingItem? item;
      
      if (kIsWeb) {
        // For web, use bytes
        item = await wardrobeProvider.addItemFromBytes(
          _imageBytes!,
          type: _selectedType!,
          color: _selectedColor!,
          styles: _selectedStyles,
          seasons: _selectedSeasons,
          material: _selectedMaterial,
        );
      } else {
        // For mobile, use file
        item = await wardrobeProvider.addItemFromFile(
          File(_pickedFile!.path),
          type: _selectedType!,
          color: _selectedColor!,
          styles: _selectedStyles,
          seasons: _selectedSeasons,
          material: _selectedMaterial,
        );
      }
      
      if (item != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã thêm vào tủ đồ!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        Navigator.pop(context);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể lưu, vui lòng thử lại'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}
