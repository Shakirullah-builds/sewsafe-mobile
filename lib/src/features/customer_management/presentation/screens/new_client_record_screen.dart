import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sewsafe_mobile/src/core/constants/app_colors.dart';
import 'package:sewsafe_mobile/src/core/widgets/custom_button.dart';
import 'package:sewsafe_mobile/src/core/widgets/custom_tab_switcher.dart';
import 'package:sewsafe_mobile/src/core/widgets/custom_text.dart';
import 'package:sewsafe_mobile/src/core/widgets/custom_textform_field.dart';
import 'package:sewsafe_mobile/src/core/widgets/loading_overlay.dart';
import 'package:sewsafe_mobile/src/features/customer_management/presentation/controller/client_controller.dart';
import 'package:sewsafe_mobile/src/features/customer_management/domain/entities/client.dart';
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

/// Custom painter to draw a smooth, resolution-independent dashed border around cards
class DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;
  final double dashLength;
  final double borderRadius;

  DashedRectPainter({
    required this.color,
    this.strokeWidth = 1.5,
    this.gap = 4.0,
    this.dashLength = 6.0,
    this.borderRadius = 12.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(borderRadius),
        ),
      );

    final dashedPath = Path();
    double distance = 0.0;

    for (final pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        final length = dashLength;
        dashedPath.addPath(
          pathMetric.extractPath(distance, distance + length),
          Offset.zero,
        );
        distance += length + gap;
      }
      distance = 0.0;
    }

    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(covariant DashedRectPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.gap != gap ||
        oldDelegate.dashLength != dashLength ||
        oldDelegate.borderRadius != borderRadius;
  }
}

class NewClientRecordScreen extends ConsumerStatefulWidget {
  final Client? client;
  const NewClientRecordScreen({super.key, this.client});

  @override
  ConsumerState<NewClientRecordScreen> createState() =>
      _NewClientRecordScreenState();
}

class _NewClientRecordScreenState extends ConsumerState<NewClientRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();

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

    // Populate client details if editing
    if (widget.client != null) {
      final client = widget.client!;
      _nameController.text = client.fullName;
      _phoneController.text = client.phoneNumber ?? '';
      _selectedGender = client.gender.toLowerCase();
      _notesController.text = client.notes ?? '';
      
      client.measurements.forEach((key, value) {
        if (_measurementControllers.containsKey(key)) {
          _measurementControllers[key]!.text = value.toString();
        } else {
          // If measurement is not standard, it's a custom field
          final pair = CustomFieldControllerPair();
          pair.nameController.text = key;
          pair.valueController.text = value.toString();
          _customFields.add(pair);
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
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
        ).showSnackBar(SnackBar(content: CustomText('Error choosing image: $e', color: Colors.white)));
      }
    }
  }

  Future<void> _saveClient() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final gender = _selectedGender;
    final notes = _notesController.text.trim();

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
              content: CustomText(
                'Note: Image upload failed ($e). Saving client without image.',
                color: Colors.white,
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

    final isEditing = widget.client != null;
    final photoUrlToUse = photoUrl ?? widget.client?.photoUrl;

    final success = isEditing
        ? await ref
            .read(clientControllerProvider.notifier)
            .editClient(
              clientId: widget.client!.id!,
              fullName: name,
              phoneNumber: phone,
              gender: gender,
              measurements: measurements,
              photoUrl: photoUrlToUse,
              notes: notes.isEmpty ? null : notes,
              stylePhotos: widget.client?.stylePhotos,
            )
        : await ref
            .read(clientControllerProvider.notifier)
            .addClient(
              fullName: name,
              phoneNumber: phone,
              gender: gender,
              measurements: measurements,
              photoUrl: photoUrlToUse,
              notes: notes.isEmpty ? null : notes,
            );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: CustomText(isEditing
              ? 'Client details updated successfully!'
              : 'New client saved successfully!', color: Colors.white),
          backgroundColor: AppColors.ready,
        ),
      );
      context.pop();
    } else if (mounted) {
      final error = ref.read(clientControllerProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: CustomText(error?.toString() ?? 'Failed to save client.', color: Colors.white),
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
            widget.client != null ? 'Edit Client Record' : 'New Client Record',
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
                  // 1. Style Photo Selector (First prominent element)
                  _buildPhotoSelector(),
                  24.verticalSpace,

                  // 2. Gender Selection (Sliding tab layout)
                  CustomText(
                    'Client Gender',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontSize: 16.spMin,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  10.verticalSpace,
                  CustomTabSwitcher(
                    selectedIndex: _selectedGender == 'male' ? 0 : 1,
                    labels: const ['Male', 'Female'],
                    icons: const [Icons.male, Icons.female],
                    onChanged: (index) {
                      setState(() {
                        _selectedGender = index == 0 ? 'male' : 'female';
                      });
                    },
                  ),
                  24.verticalSpace,

                  // 3. Basic Info Card (Client Details)
                  CustomText(
                    'Client Details',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontSize: 16.spMin,
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
                      fontSize: 16.spMin,
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
                  24.verticalSpace,

                  // 5.5. Tailoring Notes & Preferences
                  CustomText(
                    'Tailoring Notes & Preferences',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontSize: 16.spMin,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  10.verticalSpace,
                  CustomTextField(
                    controller: _notesController,
                    hintText: 'e.g. prefers loose sleeves, lining required',
                    headerText: 'Notes',
                    maxLines: 3,
                  ),
                  40.verticalSpace,

                  // 6. Action Button
                  CustomButton(
                    text: widget.client != null ? 'Update Client Record' : 'Save Client Record',
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

  Widget _buildPhotoSelector() {
    final theme = Theme.of(context);
    final hasExistingPhoto = widget.client?.photoUrl != null;

    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 240.h,
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
                    top: 12.h,
                    right: 12.w,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedImage = null;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 18.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : hasExistingPhoto
                ? Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16.r),
                        child: Image.network(
                          widget.client!.photoUrl!,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(
                                Icons.broken_image,
                                color: AppColors.notification,
                              ),
                            );
                          },
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                      Center(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 16.sp,
                              ),
                              8.horizontalSpace,
                              CustomText(
                                'Change Photo',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.spMin,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_a_photo_rounded,
                        color: AppColors.primary,
                        size: 40.sp,
                      ),
                      12.verticalSpace,
                      CustomText(
                        'Upload Style Photo',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 15.spMin,
                        ),
                      ),
                      6.verticalSpace,
                      CustomText(
                        'Tap to choose from gallery',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textBody.withValues(alpha: 0.7),
                          fontSize: 12.spMin,
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
          child: CustomText(
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
        CustomText(
          'Custom Measurements',
          style: theme.textTheme.bodyLarge?.copyWith(
            fontSize: 16.spMin,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        10.verticalSpace,
        if (_customFields.isEmpty)
          Padding(
            padding: EdgeInsets.only(bottom: 12.h),
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
        else ...[
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
                        child: CustomText(
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
          16.verticalSpace,
        ],
        // 6. Prominent Dashed-Border Action Card Button
        CustomPaint(
          painter: DashedRectPainter(
            color: AppColors.primary,
            borderRadius: 12.r,
          ),
          child: GestureDetector(
            onTap: () {
              setState(() {
                _customFields.add(CustomFieldControllerPair());
              });
            },
            child: Container(
              height: 56.h,
              width: double.infinity,
              color: Colors.transparent, // Capture gestures in full area
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_circle_outline,
                    color: AppColors.primary,
                    size: 20.sp,
                  ),
                  8.horizontalSpace,
                  CustomText(
                    'Add Custom Measurement',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.spMin,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
