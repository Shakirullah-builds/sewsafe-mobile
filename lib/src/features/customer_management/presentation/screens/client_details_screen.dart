import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sewsafe_mobile/src/core/constants/app_colors.dart';
import 'package:sewsafe_mobile/src/core/route/app_route.dart';
import 'package:sewsafe_mobile/src/core/widgets/custom_button.dart';
import 'package:sewsafe_mobile/src/core/widgets/custom_text.dart';
import 'package:sewsafe_mobile/src/features/customer_management/domain/entities/client.dart';
import 'package:sewsafe_mobile/src/features/customer_management/presentation/controller/client_controller.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class ClientDetailsScreen extends ConsumerWidget {
  final Client client;

  const ClientDetailsScreen({super.key, required this.client});

  /// Generates a premium pastel background color based on name hash
  Color _getAvatarColor(String name) {
    final int hash = name.codeUnits.fold(0, (prev, element) => prev + element);
    final double hue = (hash * 137.5) % 360;
    return HSLColor.fromAHSL(1.0, hue, 0.45, 0.90).toColor();
  }

  /// Generates a dark contrasting text color based on name hash
  Color _getAvatarTextColor(String name) {
    final int hash = name.codeUnits.fold(0, (prev, element) => prev + element);
    final double hue = (hash * 137.5) % 360;
    return HSLColor.fromAHSL(1.0, hue, 0.70, 0.35).toColor();
  }

  /// Extracts up to two initials from the client's full name
  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || name.trim().isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  /// Opens WhatsApp with a pre-filled list of measurements
  Future<void> _shareOnWhatsApp(BuildContext context, Client liveClient) async {
    if (liveClient.phoneNumber == null || liveClient.phoneNumber!.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: CustomText('Cannot share: Client has no phone number saved.', color: Colors.white),
          backgroundColor: AppColors.notification,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final buffer = StringBuffer();
    buffer.writeln('Hello ${liveClient.fullName},');
    buffer.writeln('Here are your body measurements recorded on SewSafe:');
    buffer.writeln();
    
    liveClient.measurements.forEach((key, value) {
      buffer.writeln('• $key: $value in');
    });

    if (liveClient.notes != null && liveClient.notes!.trim().isNotEmpty) {
      buffer.writeln();
      buffer.writeln('Notes: ${liveClient.notes}');
    }

    buffer.writeln();
    buffer.writeln('Shared via SewSafe - "Never lose a measurement."');

    final messageText = buffer.toString();
    
    // Sanitize phone number digits
    final cleanPhone = liveClient.phoneNumber!.replaceAll(RegExp(r'[^\d+]'), '');
    final urlString = 'https://wa.me/${cleanPhone.replaceFirst('+', '')}?text=${Uri.encodeComponent(messageText)}';
    final url = Uri.parse(urlString);

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        // Fallback to web link launch
        await launchUrl(url, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: CustomText('Could not open WhatsApp: $e', color: Colors.white),
            backgroundColor: AppColors.notification,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Initiates a standard phone call
  Future<void> _callClient(BuildContext context, Client liveClient) async {
    if (liveClient.phoneNumber == null || liveClient.phoneNumber!.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: CustomText('Cannot call: Client has no phone number saved.', color: Colors.white),
          backgroundColor: AppColors.notification,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final cleanPhone = liveClient.phoneNumber!.replaceAll(RegExp(r'[^\d+]'), '');
    final url = Uri.parse('tel:$cleanPhone');

    try {
      final launched = await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: CustomText('Your device cannot place phone calls directly.', color: Colors.white),
            backgroundColor: AppColors.notification,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: CustomText('Could not trigger call: $e', color: Colors.white),
            backgroundColor: AppColors.notification,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the live list of clients to ensure reactive updates propagate immediately
    final clientsAsync = ref.watch(clientsListProvider);
    final liveClient = clientsAsync.maybeWhen(
      data: (list) => list.firstWhere((c) => c.id == client.id, orElse: () => client),
      orElse: () => client,
    );

    final initials = _getInitials(liveClient.fullName);
    final avatarColor = _getAvatarColor(liveClient.fullName);
    final avatarTextColor = _getAvatarTextColor(liveClient.fullName);
    final updateTime = liveClient.updatedAt ?? liveClient.createdAt;
    final formattedDate = updateTime != null
        ? DateFormat('MMM dd, yyyy').format(updateTime)
        : 'Unknown Date';

    final List<Map<String, String>> allPhotos = [];
    if (liveClient.stylePhotos != null) {
      allPhotos.addAll(liveClient.stylePhotos!);
    } else if (liveClient.photoUrl != null) {
      allPhotos.add({
        'url': liveClient.photoUrl!,
        'uploadedAt': liveClient.createdAt != null
            ? liveClient.createdAt!.toIso8601String()
            : DateTime.now().toIso8601String(),
      });
    }

    String lastUploadDate = 'Date unknown';
    if (allPhotos.isNotEmpty) {
      final uploadedAtStr = allPhotos.last['uploadedAt'];
      if (uploadedAtStr != null && uploadedAtStr.isNotEmpty) {
        try {
          final date = DateTime.parse(uploadedAtStr);
          lastUploadDate = 'Uploaded on ${DateFormat('MMM dd, yyyy').format(date)}';
        } catch (_) {}
      }
    }

    return Scaffold(
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
          'Client Profile',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18.spMin,
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.edit_outlined,
              color: AppColors.primary,
            ),
            onPressed: () {
              // Open NewClientRecordScreen in edit mode, passing client data
              context.pushNamed(AppRoute.addClient.name, extra: liveClient);
            },
          ),
          12.horizontalSpace,
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Profile Header block
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 72.r,
                          height: 72.r,
                          decoration: BoxDecoration(
                            color: avatarColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.black.withValues(alpha: 0.05),
                              width: 0.5.w,
                            ),
                          ),
                          child: Center(
                            child: CustomText(
                              initials,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 24.spMin,
                                fontWeight: FontWeight.bold,
                                color: avatarTextColor,
                              ),
                            ),
                          ),
                        ),
                        20.horizontalSpace,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomText(
                                liveClient.fullName,
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 24.spMin,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              4.verticalSpace,
                              Row(
                                children: [
                                  Icon(
                                    Icons.phone_outlined,
                                    size: 16.r,
                                    color: AppColors.textBody,
                                  ),
                                  6.horizontalSpace,
                                  CustomText(
                                    liveClient.phoneNumber ?? 'No phone number',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14.spMin,
                                      color: AppColors.textBody,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              8.verticalSpace,
                              // Gender Badge
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: liveClient.gender.toLowerCase() == 'male'
                                      ? AppColors.primary.withValues(
                                          alpha: 0.08,
                                        )
                                      : Colors.pink.withValues(
                                          alpha: 0.08,
                                        ),
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      liveClient.gender.toLowerCase() == 'male'
                                          ? Icons.male
                                          : Icons.female,
                                      size: 14.r,
                                      color: liveClient.gender.toLowerCase() == 'male'
                                          ? AppColors.primary
                                          : Colors.pink[400],
                                    ),
                                    4.horizontalSpace,
                                    CustomText(
                                      liveClient.gender[0].toUpperCase() +
                                          liveClient.gender.substring(1),
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12.spMin,
                                        fontWeight: FontWeight.bold,
                                        color: liveClient.gender.toLowerCase() == 'male'
                                            ? AppColors.primary
                                            : Colors.pink[400],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    24.verticalSpace,

                    // 2. Communication Actions
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF25D366), // WhatsApp Green
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            icon: const Icon(Icons.share, color: Colors.white, size: 18),
                            label: CustomText(
                              'WhatsApp Share',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14.spMin,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            onPressed: () => _shareOnWhatsApp(context, liveClient),
                          ),
                        ),
                        16.horizontalSpace,
                        Container(
                          height: 48.r,
                          width: 48.r,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceWhite,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: AppColors.placeholder.withValues(alpha: 0.8),
                            ),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.phone_outlined,
                              color: AppColors.primary,
                            ),
                            onPressed: () => _callClient(context, liveClient),
                          ),
                        ),
                      ],
                    ),
                    24.verticalSpace,

                    // 3. Style Gallery Preview Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomText(
                          'Style References',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16.spMin,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (allPhotos.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              context.pushNamed(
                                AppRoute.clientStyleGallery.name,
                                extra: liveClient,
                              );
                            },
                            child: CustomText(
                              'View Gallery (${allPhotos.length})',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.spMin,
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    10.verticalSpace,
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceWhite,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: AppColors.placeholder.withValues(alpha: 0.8),
                        ),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16.r),
                        onTap: () {
                          context.pushNamed(
                            AppRoute.clientStyleGallery.name,
                            extra: liveClient,
                          );
                        },
                        child: Padding(
                          padding: EdgeInsets.all(16.r),
                          child: allPhotos.isEmpty
                              ? Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(12.r),
                                      decoration: BoxDecoration(
                                        color: AppColors.placeholder.withValues(alpha: 0.3),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.image_outlined,
                                        color: AppColors.textBody,
                                        size: 24.r,
                                      ),
                                    ),
                                    16.horizontalSpace,
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          CustomText(
                                            'No style references saved',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 14.spMin,
                                              color: AppColors.textSecondary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          2.verticalSpace,
                                          CustomText(
                                            'Upload photos to keep track of styles.',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 12.spMin,
                                              color: AppColors.textBody,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.add_photo_alternate_outlined,
                                      color: AppColors.primary,
                                      size: 20.r,
                                    ),
                                  ],
                                )
                              : Row(
                                  children: [
                                    // Thumbnail of the latest image
                                    Container(
                                      width: 56.r,
                                      height: 56.r,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12.r),
                                        color: AppColors.placeholder.withValues(alpha: 0.2),
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      child: Image.network(
                                        allPhotos.last['url'] ?? '',
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
                                        errorBuilder: (context, error, stackTrace) => Icon(
                                          Icons.broken_image,
                                          color: AppColors.notification,
                                          size: 20.r,
                                        ),
                                      ),
                                    ),
                                    16.horizontalSpace,
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          CustomText(
                                            'Latest Reference',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 14.spMin,
                                              color: AppColors.textSecondary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          2.verticalSpace,
                                          CustomText(
                                            lastUploadDate,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 12.spMin,
                                              color: AppColors.textBody,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CustomText(
                                          'Open Gallery',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 12.spMin,
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        4.horizontalSpace,
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          size: 12.r,
                                          color: AppColors.primary,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                    24.verticalSpace,

                    // 4. Measurements Header with last-updated timestamp
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              'Measurements',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16.spMin,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            4.verticalSpace,
                            CustomText(
                              'Last updated: $formattedDate',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.spMin,
                                color: AppColors.textBody,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.placeholder.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: CustomText(
                            'Inches',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.spMin,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    12.verticalSpace,

                    // 5. Measurements Grid view
                    liveClient.measurements.isEmpty
                        ? Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(vertical: 24.h),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceWhite,
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(
                                color: AppColors.placeholder.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                            ),
                            child: Center(
                              child: CustomText(
                                'No measurements recorded.',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14.spMin,
                                  color: AppColors.textBody,
                                ),
                              ),
                            ),
                          )
                        : GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16.w,
                              mainAxisSpacing: 12.h,
                              childAspectRatio: 2.2,
                            ),
                            itemCount: liveClient.measurements.length,
                            itemBuilder: (context, index) {
                              final key =
                                  liveClient.measurements.keys.elementAt(index);
                              final value = liveClient.measurements[key];

                              return Container(
                                padding: EdgeInsets.all(12.r),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceWhite,
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(
                                    color: AppColors.placeholder.withValues(
                                      alpha: 0.8,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CustomText(
                                      key,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13.spMin,
                                        color: AppColors.textBody,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    4.verticalSpace,
                                    CustomText(
                                      '$value in',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 16.spMin,
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                    24.verticalSpace,

                    // 6. Tailoring Notes Preference Card
                    if (liveClient.notes != null &&
                        liveClient.notes!.trim().isNotEmpty) ...[
                      CustomText(
                        'Tailoring Notes',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16.spMin,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      10.verticalSpace,
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16.r),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceWhite,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: AppColors.placeholder.withValues(
                              alpha: 0.8,
                            ),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.format_quote_rounded,
                              color: AppColors.primary.withValues(alpha: 0.4),
                              size: 24.r,
                            ),
                            12.horizontalSpace,
                            Expanded(
                              child: CustomText(
                                liveClient.notes!,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14.spMin,
                                  color: AppColors.textSecondary,
                                  height: 1.4,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      24.verticalSpace,
                    ],
                  ],
                ),
              ),
            ),

            // 7. Fixed Bottom Create New Order trigger button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: CustomButton(
                text: 'Create New Order',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: CustomText(
                        'New Order creation for ${liveClient.fullName} is coming soon in the next feature phase!',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 14.spMin,
                        ),
                      ),
                      backgroundColor: AppColors.primary,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
