import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sewsafe_mobile/src/core/constants/app_colors.dart';
import 'package:sewsafe_mobile/src/core/widgets/custom_button.dart';
import 'package:sewsafe_mobile/src/core/widgets/custom_text.dart';
import 'package:sewsafe_mobile/src/core/widgets/custom_textform_field.dart';
import 'package:sewsafe_mobile/src/core/widgets/loading_overlay.dart';
import 'package:sewsafe_mobile/src/features/customer_management/presentation/controller/client_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Controller pair to manage dynamic custom text inputs
class CustomFieldControllerPair {
  final TextEditingController nameController;
  final TextEditingController valueController;

  CustomFieldControllerPair()
    : nameController = TextEditingController(),
      valueController = TextEditingController();

  void dispose() {
    nameController.dispose();
    valueController.dispose();
  }
}

class NewClientRecordScreen extends ConsumerStatefulWidget {
  const NewClientRecordScreen({super.key});

  @override
  ConsumerState<NewClientRecordScreen> createState() =>
      _NewClientRecordScreenState();
}

class _NewClientRecordScreenState extends ConsumerState<NewClientRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  String _selectedGender = 'male';
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isUploadingImage = false;

  // Cache of measurement controllers for both genders to preserve values when toggling
  final Map<String, TextEditingController> _measurementControllers = {};

  // List of active custom key-value pairs
  final List<CustomFieldControllerPair> _customFields = [];

  final List<String> _maleKeys = [
    'Neck',
    'Shoulder',
    'Chest',
    'Sleeve',
    'Waist',
    'Hips',
    'Inseam',
    'Shirt Length',
    'Trouser Length',
  ];

  final List<String> _femaleKeys = [
    'Neck',
    'Bust',
    'Underbust',
    'Shoulder',
    'Sleeve',
    'Waist',
    'Hips',
    'Blouse Length',
    'Skirt/Trouser Length',
  ];

  @override
  void initState() {
    super.initState();
    // Initialize standard controllers for both genders
    for (final key in [..._maleKeys, ..._femaleKeys]) {
      _measurementControllers[key] = TextEditingController();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    for (final controller in _measurementControllers.values) {
      controller.dispose();
    }
    for (final pair in _customFields) {
      pair.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error choosing image: $e')));
      }
    }
  }

  Future<void> _saveClient() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final gender = _selectedGender;

    // Compile active standard measurements
    final Map<String, double> measurements = {};
    final activeKeys = gender == 'male' ? _maleKeys : _femaleKeys;

    for (final key in activeKeys) {
      final text = _measurementControllers[key]?.text.trim() ?? '';
      if (text.isNotEmpty) {
        final value = double.tryParse(text);
        if (value != null) {
          measurements[key] = value;
        }
      }
    }

    // Compile active custom measurements
    for (final pair in _customFields) {
      final key = pair.nameController.text.trim();
      final valText = pair.valueController.text.trim();
      if (key.isNotEmpty && valText.isNotEmpty) {
        final value = double.tryParse(valText);
        if (value != null) {
          measurements[key] = value;
        }
      }
    }

    String? photoUrl;

    if (_selectedImage != null) {
      setState(() => _isUploadingImage = true);
      try {
        final supabase = Supabase.instance.client;
        final user = supabase.auth.currentUser;
        if (user != null) {
          final fileBytes = await _selectedImage!.readAsBytes();
          final fileExt = _selectedImage!.path.split('.').last;
          final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
          final path = '${user.id}/$fileName';

          // Try uploading to Supabase Storage bucket 'client-styles'
          await supabase.storage
              .from('client-styles')
              .uploadBinary(path, fileBytes);

          // Retrieve public url
          photoUrl = supabase.storage.from('client-styles').getPublicUrl(path);
        }
      } catch (e) {
        debugPrint('Image upload failed: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Note: Image upload failed ($e). Saving client without image.',
              ),
              backgroundColor: AppColors.notification,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isUploadingImage = false);
        }
      }
    }

    final success = await ref
        .read(clientControllerProvider.notifier)
        .addClient(
          name: name,
          phone: phone,
          gender: gender,
          measurements: measurements,
          photoUrl: photoUrl,
        );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('New client saved successfully!'),
          backgroundColor: AppColors.ready,
        ),
      );
      context.pop();
    } else if (mounted) {
      final error = ref.read(clientControllerProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error?.toString() ?? 'Failed to save client.'),
          backgroundColor: AppColors.notification,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final clientState = ref.watch(clientControllerProvider);
    final activeKeys = _selectedGender == 'male' ? _maleKeys : _femaleKeys;

    return LoadingOverlay(
      isLoading: clientState.isLoading || _isUploadingImage,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: AppColors.textSecondary,
            ),
            onPressed: () => context.pop(),
          ),
          title: CustomText(
            'New Client Record',
            style: theme.textTheme.titleLarge?.copyWith(
              fontSize: 18.spMin,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: _saveClient,
              child: CustomText(
                'Save',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.spMin,
                ),
              ),
            ),
            12.horizontalSpace,
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Gender Selection
                  CustomText(
                    'Client Gender',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontSize: 14.spMin,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  10.verticalSpace,
                  _buildGenderSelector(),
                  24.verticalSpace,

                  // 2. Style Photo Selector
                  CustomText(
                    'Style Reference Photo',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontSize: 14.spMin,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  10.verticalSpace,
                  _buildPhotoSelector(),
                  24.verticalSpace,

                  // 3. Basic Info Card
                  CustomText(
                    'Client Information',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontSize: 14.spMin,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  10.verticalSpace,
                  CustomTextField(
                    controller: _nameController,
                    hintText: 'Enter client name',
                    headerText: 'Full Name *',
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Client name is required';
                      }
                      return null;
                    },
                  ),
                  16.verticalSpace,
                  CustomTextField(
                    controller: _phoneController,
                    hintText: 'e.g., +234 800 000 0000',
                    headerText: 'Phone Number (Optional)',
                    keyboardType: TextInputType.phone,
                  ),
                  24.verticalSpace,

                  // 4. Standard Measurements
                  CustomText(
                    'Standard Measurements',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontSize: 14.spMin,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  10.verticalSpace,
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16.w,
                      mainAxisSpacing: 8.h,
                      childAspectRatio: 1.6,
                    ),
                    itemCount: activeKeys.length,
                    itemBuilder: (context, index) {
                      final key = activeKeys[index];
                      return _buildMeasurementField(
                        key,
                        _measurementControllers[key]!,
                      );
                    },
                  ),
                  20.verticalSpace,

                  // 5. Dynamic Custom Section
                  _buildCustomFieldsSection(),
                  40.verticalSpace,

                  // 6. Action Button
                  CustomButton(
                    text: 'Save Client Record',
                    onPressed: _saveClient,
                  ),
                  24.verticalSpace,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGenderSelector() {
    return Row(
      children: [
        Expanded(
          child: _buildGenderButton(
            gender: 'male',
            label: 'Male',
            icon: Icons.male,
            isSelected: _selectedGender == 'male',
          ),
        ),
        16.horizontalSpace,
        Expanded(
          child: _buildGenderButton(
            gender: 'female',
            label: 'Female',
            icon: Icons.female,
            isSelected: _selectedGender == 'female',
          ),
        ),
      ],
    );
  }

  Widget _buildGenderButton({
    required String gender,
    required String label,
    required IconData icon,
    required bool isSelected,
  }) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGender = gender;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.placeholder,
            width: 1.5.w,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.textBody,
              size: 20.sp,
            ),
            8.horizontalSpace,
            CustomText(
              label,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 14.spMin,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSelector() {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 140.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: AppColors.stroke.withValues(alpha: 0.4),
            width: 1.5.w,
          ),
        ),
        child: _selectedImage != null
            ? Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16.r),
                    child: Image.file(
                      _selectedImage!,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 8.h,
                    right: 8.w,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedImage = null;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(6.r),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_alt_outlined,
                    color: AppColors.primary,
                    size: 32.sp,
                  ),
                  8.verticalSpace,
                  CustomText(
                    'Upload Style Reference Photo',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13.spMin,
                    ),
                  ),
                  4.verticalSpace,
                  CustomText(
                    'Tap to choose from gallery',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textBody.withValues(alpha: 0.7),
                      fontSize: 11.spMin,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildMeasurementField(
    String label,
    TextEditingController controller,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: CustomTextField(
        controller: controller,
        hintText: '0.0',
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        headerText: label,
        suffixIcon: Padding(
          padding: EdgeInsets.only(right: 12.w, top: 14.h),
          child: Text(
            'in',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textBody.withValues(alpha: 0.6),
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ),
    );
  }

  Widget _buildCustomFieldsSection() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomText(
              'Custom Measurements',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontSize: 14.spMin,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _customFields.add(CustomFieldControllerPair());
                });
              },
              icon: Icon(
                Icons.add_circle_outline,
                size: 18.sp,
                color: AppColors.primary,
              ),
              label: CustomText(
                'Add Custom',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13.spMin,
                ),
              ),
            ),
          ],
        ),
        if (_customFields.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: AppColors.placeholder.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: CustomText(
                'No custom measurements added yet (e.g. Cap, Head).',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textBody.withValues(alpha: 0.7),
                  fontSize: 12.spMin,
                ),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _customFields.length,
            separatorBuilder: (context, index) => 12.verticalSpace,
            itemBuilder: (context, index) {
              final pair = _customFields[index];
              return Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Label Field
                  Expanded(
                    flex: 5,
                    child: CustomTextField(
                      controller: pair.nameController,
                      hintText: 'e.g., Cap Size',
                      headerText: 'Label',
                      //keyboardType: TextInputType.,
                    ),
                  ),
                  12.horizontalSpace,
                  // Value Field
                  Expanded(
                    flex: 3,
                    child: CustomTextField(
                      controller: pair.valueController,
                      hintText: '0.0',
                      headerText: 'Value',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      suffixIcon: Padding(
                        padding: EdgeInsets.only(right: 12.w, top: 14.h),
                        child: Text(
                          'in',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textBody.withValues(alpha: 0.6),
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ),
                  ),
                  8.horizontalSpace,
                  // Delete Button
                  IconButton(
                    onPressed: () {
                      setState(() {
                        pair.dispose();
                        _customFields.removeAt(index);
                      });
                    },
                    icon: Icon(
                      Icons.delete_outline,
                      color: AppColors.notification,
                      size: 24.sp,
                    ),
                  ),
                ],
              );
            },
          ),
      ],
    );
  }
}
