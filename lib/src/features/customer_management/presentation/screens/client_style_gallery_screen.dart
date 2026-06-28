import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:sewsafe_mobile/src/core/constants/app_colors.dart';
import 'package:sewsafe_mobile/src/core/widgets/custom_empty_state.dart';
import 'package:sewsafe_mobile/src/core/widgets/custom_text.dart';
import 'package:sewsafe_mobile/src/core/widgets/loading_overlay.dart';
import 'package:sewsafe_mobile/src/features/customer_management/domain/entities/client.dart';
import 'package:sewsafe_mobile/src/features/customer_management/presentation/controller/client_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ClientStyleGalleryScreen extends ConsumerStatefulWidget {
  final Client client;

  const ClientStyleGalleryScreen({super.key, required this.client});

  @override
  ConsumerState<ClientStyleGalleryScreen> createState() => _ClientStyleGalleryScreenState();
}

class _ClientStyleGalleryScreenState extends ConsumerState<ClientStyleGalleryScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  String _loadingText = 'Uploading Style Photo...';

  /// Generates a human-friendly string for the day header
  String _formatGroupDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final targetDate = DateTime(date.year, date.month, date.day);

    if (targetDate == today) {
      return 'Today';
    } else if (targetDate == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('MMMM dd, yyyy').format(date);
    }
  }

  /// Handles photo uploads, database updates, and error alerts
  Future<void> _uploadNewPhoto(Client client) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image == null) return;

      setState(() {
        _loadingText = 'Uploading Style Photo...';
        _isUploading = true;
      });

      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated.');

      final fileBytes = await image.readAsBytes();
      final fileExt = image.path.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final storagePath = '${user.id}/$fileName';

      // Upload to Supabase Storage bucket 'client-styles'
      await supabase.storage
          .from('client-styles')
          .uploadBinary(storagePath, fileBytes);

      // Get public URL
      final newPhotoUrl = supabase.storage.from('client-styles').getPublicUrl(storagePath);

      // Create new photo item
      final newPhotoItem = {
        'url': newPhotoUrl,
        'uploadedAt': DateTime.now().toIso8601String(),
      };

      // Compile updated list of style photos
      final List<Map<String, String>> updatedStylePhotos = [];
      if (client.stylePhotos != null) {
        updatedStylePhotos.addAll(client.stylePhotos!);
      } else if (client.photoUrl != null) {
        // Migration of legacy photoUrl to stylePhotos
        updatedStylePhotos.add({
          'url': client.photoUrl!,
          'uploadedAt': client.createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
        });
      }
      updatedStylePhotos.add(newPhotoItem);

      // Save to database by calling editClient, preserving profile avatar
      final success = await ref.read(clientControllerProvider.notifier).editClient(
        clientId: client.id!,
        fullName: client.fullName,
        phoneNumber: client.phoneNumber ?? '',
        gender: client.gender,
        measurements: client.measurements,
        photoUrl: client.photoUrl, // Preserve profile picture url
        notes: client.notes,
        stylePhotos: updatedStylePhotos,
      );

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: CustomText('Style reference photo uploaded successfully!', color: Colors.white),
              backgroundColor: AppColors.ready,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        final error = ref.read(clientControllerProvider).error;
        throw Exception(error?.toString() ?? 'Failed to update client record.');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: CustomText('Failed to upload photo: $e', color: Colors.white),
            backgroundColor: AppColors.notification,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  /// Deletes a chosen photo after confirmation
  Future<void> _deletePhoto(Client client, Map<String, String> photoItem) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceWhite,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: CustomText(
          'Delete Photo',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18.spMin,
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
          ),
        ),
        content: CustomText(
          'Are you sure you want to delete this style reference photo?',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14.spMin,
            color: AppColors.textBody,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: CustomText(
              'Cancel',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
                color: AppColors.textBody,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: CustomText(
              'Delete',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                color: AppColors.notification,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _loadingText = 'Deleting Style Photo...';
      _isUploading = true;
    });

    try {
      final List<Map<String, String>> updatedStylePhotos = [];
      if (client.stylePhotos != null) {
        updatedStylePhotos.addAll(client.stylePhotos!);
      } else if (client.photoUrl != null) {
        updatedStylePhotos.add({
          'url': client.photoUrl!,
          'uploadedAt': client.createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
        });
      }
      
      // Remove photo item
      updatedStylePhotos.removeWhere((item) => item['url'] == photoItem['url']);

      // If the deleted photo matches the legacy primary photoUrl, clear it
      final newPhotoUrl = client.photoUrl == photoItem['url'] ? null : client.photoUrl;

      // Save to database, keeping photoUrl updated to reflect deletion
      final success = await ref.read(clientControllerProvider.notifier).editClient(
        clientId: client.id!,
        fullName: client.fullName,
        phoneNumber: client.phoneNumber ?? '',
        gender: client.gender,
        measurements: client.measurements,
        photoUrl: newPhotoUrl,
        notes: client.notes,
        stylePhotos: updatedStylePhotos.isEmpty ? null : updatedStylePhotos,
      );

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: CustomText('Style reference photo deleted successfully!', color: Colors.white),
              backgroundColor: AppColors.ready,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: CustomText('Failed to delete photo: $e', color: Colors.white),
            backgroundColor: AppColors.notification,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  /// Displays full-screen image overlay modal with zoom functionality and deletion triggers
  void _zoomPhoto(BuildContext context, Client client, Map<String, String> photoItem) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.95),
      builder: (context) {
        return GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Stack(
            children: [
              InteractiveViewer(
                child: Center(
                  child: Image.network(
                    photoItem['url'] ?? '',
                    fit: BoxFit.contain,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
              Positioned(
                top: 40.h,
                right: 20.w,
                child: Material(
                  color: Colors.black54,
                  shape: const CircleBorder(),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
              Positioned(
                bottom: 40.h,
                left: 0,
                right: 0,
                child: Center(
                  child: Material(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20.r),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.calendar_today_outlined, size: 14.r, color: Colors.white70),
                          8.horizontalSpace,
                          CustomText(
                            photoItem['uploadedAt'] != null && photoItem['uploadedAt']!.isNotEmpty
                                ? DateFormat('MMMM dd, yyyy').format(DateTime.parse(photoItem['uploadedAt']!))
                                : 'Upload date unknown',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.spMin,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          16.horizontalSpace,
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: AppColors.notification, size: 20),
                            onPressed: () {
                              Navigator.pop(context);
                              _deletePhoto(client, photoItem);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch client controller to keep the autoDispose notifier alive
    ref.watch(clientControllerProvider);

    // Listen to real-time updates of the client list in order to auto-update style images
    final clientsAsync = ref.watch(clientsListProvider);
    final client = clientsAsync.maybeWhen(
      data: (list) => list.firstWhere((c) => c.id == widget.client.id, orElse: () => widget.client),
      orElse: () => widget.client,
    );

    // Consolidate list of photo maps
    final List<Map<String, String>> allPhotos = [];
    if (client.stylePhotos != null) {
      allPhotos.addAll(client.stylePhotos!);
    } else if (client.photoUrl != null) {
      allPhotos.add({
        'url': client.photoUrl!,
        'uploadedAt': client.createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      });
    }

    // Group photos by day: e.g., Map<DateTime, List<Map<String, String>>>
    final Map<DateTime, List<Map<String, String>>> tempGroups = {};
    for (final photo in allPhotos) {
      final uploadedAtStr = photo['uploadedAt'];
      DateTime day = DateTime(1970, 1, 1);
      if (uploadedAtStr != null && uploadedAtStr.isNotEmpty) {
        try {
          final date = DateTime.parse(uploadedAtStr);
          day = DateTime(date.year, date.month, date.day);
        } catch (_) {}
      }
      if (!tempGroups.containsKey(day)) {
        tempGroups[day] = [];
      }
      tempGroups[day]!.add(photo);
    }

    // Sort the days in descending order
    final sortedDays = tempGroups.keys.toList()..sort((a, b) => b.compareTo(a));

    // Sort photos within each day descending
    for (final day in sortedDays) {
      tempGroups[day]!.sort((a, b) {
        final aTimeStr = a['uploadedAt'] ?? '';
        final bTimeStr = b['uploadedAt'] ?? '';
        return bTimeStr.compareTo(aTimeStr);
      });
    }

    return LoadingOverlay(
      isLoading: _isUploading,
      loadingText: _loadingText,
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
            'Style Gallery',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18.spMin,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.add_a_photo_outlined,
                color: AppColors.primary,
              ),
              onPressed: () => _uploadNewPhoto(client),
            ),
            12.horizontalSpace,
          ],
        ),
        body: SafeArea(
          child: allPhotos.isEmpty
              ? Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32.w),
                  child: Center(
                    child: CustomEmptyState(
                      title: 'No style references yet',
                      subtitle: 'Upload style references or snap screenshots to record references.',
                      imageWidget: Container(
                        width: 150.r,
                        height: 150.r,
                        padding: EdgeInsets.all(24.r),
                        decoration: BoxDecoration(
                          color: AppColors.placeholder.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.photo_library_outlined,
                          size: 64.r,
                          color: AppColors.primary,
                        ),
                      ),
                      buttonText: 'Upload First Photo',
                      onButtonPressed: () => _uploadNewPhoto(client),
                    ),
                  ),
                )
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                  itemCount: sortedDays.length + 1, // +1 for the header
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 20.h),
                        child: CustomText(
                          '${client.fullName}\'s References (${allPhotos.length})',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16.spMin,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      );
                    }

                    final day = sortedDays[index - 1];
                    final dayPhotos = tempGroups[day]!;
                    final formattedGroupDate = _formatGroupDate(day);

                    return Padding(
                      padding: EdgeInsets.only(bottom: 24.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Sticky-like Day Subheader
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 14.r,
                                color: AppColors.primary,
                              ),
                              8.horizontalSpace,
                              CustomText(
                                formattedGroupDate,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14.spMin,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              12.horizontalSpace,
                              Expanded(
                                child: Divider(
                                  color: AppColors.placeholder.withValues(alpha: 0.5),
                                  thickness: 0.8.h,
                                ),
                              ),
                            ],
                          ),
                          14.verticalSpace,
                          // Nested GridView for the day's photos
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12.w,
                              mainAxisSpacing: 12.h,
                              childAspectRatio: 1.0,
                            ),
                            itemCount: dayPhotos.length,
                            itemBuilder: (context, gridIndex) {
                              final photoItem = dayPhotos[gridIndex];
                              return Container(
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceWhite,
                                  borderRadius: BorderRadius.circular(16.r),
                                  border: Border.all(
                                    color: AppColors.placeholder.withValues(alpha: 0.8),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.02),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: InkWell(
                                  onTap: () => _zoomPhoto(context, client, photoItem),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.network(
                                        photoItem['url'] ?? '',
                                        fit: BoxFit.cover,
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null) return child;
                                          return const Center(
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: AppColors.primary,
                                            ),
                                          );
                                        },
                                        errorBuilder: (context, error, stackTrace) => const Center(
                                          child: Icon(
                                            Icons.broken_image,
                                            color: AppColors.notification,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 8.h,
                                        right: 8.w,
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            color: Colors.black45,
                                            shape: BoxShape.circle,
                                          ),
                                          child: IconButton(
                                            padding: EdgeInsets.zero,
                                            constraints: BoxConstraints.tight(Size(28.r, 28.r)),
                                            icon: const Icon(
                                              Icons.delete_outline,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                            onPressed: () => _deletePhoto(client, photoItem),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
