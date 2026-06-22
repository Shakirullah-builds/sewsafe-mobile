import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sewsafe_mobile/src/core/constants/app_colors.dart';
import 'package:sewsafe_mobile/src/core/route/app_route.dart';
import 'package:sewsafe_mobile/src/core/widgets/custom_empty_state.dart';
import 'package:sewsafe_mobile/src/core/widgets/custom_text.dart';
import 'package:sewsafe_mobile/src/core/constants/app_icons.dart';
import 'package:sewsafe_mobile/src/features/customer_management/domain/entities/client.dart';
import 'package:sewsafe_mobile/src/features/customer_management/presentation/controller/client_controller.dart';

/// Riverpod StateProvider to track the search query in real-time
final clientsSearchQueryProvider = StateProvider<String>((ref) => '');

/// Riverpod Provider that filters the database clients list based on search query
final filteredClientsProvider = Provider<List<Client>>((ref) {
  final clientsAsync = ref.watch(clientsListProvider);
  final query = ref.watch(clientsSearchQueryProvider).trim().toLowerCase();

  return clientsAsync.maybeWhen(
    data: (clients) {
      if (query.isEmpty) return clients;
      return clients.where((client) {
        final matchesName = client.fullName.toLowerCase().contains(query);
        final matchesPhone =
            client.phoneNumber?.toLowerCase().contains(query) ?? false;
        return matchesName || matchesPhone;
      }).toList();
    },
    orElse: () => [],
  );
});

class ClientsScreen extends ConsumerStatefulWidget {
  const ClientsScreen({super.key});

  @override
  ConsumerState<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends ConsumerState<ClientsScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Generates a premium pastel background color based on name hash
  Color _getAvatarColor(String name) {
    final int hash = name.codeUnits.fold(0, (prev, element) => prev + element);
    final double hue = (hash * 137.5) % 360; // Golden ratio hue distribution
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

  @override
  Widget build(BuildContext context) {
    final clientsAsyncValue = ref.watch(clientsListProvider);
    final filteredClients = ref.watch(filteredClientsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomText(
                    'Clients Directory',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 28.spMin,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      ref.invalidate(clientsListProvider);
                    },
                    icon: Icon(
                      Icons.refresh,
                      color: AppColors.textBody,
                      size: 24.r,
                    ),
                  ),
                ],
              ),
              4.verticalSpace,
              CustomText(
                'Manage measurements and details for your clients.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.spMin,
                  color: AppColors.textBody,
                  fontWeight: FontWeight.w400,
                ),
              ),
              20.verticalSpace,

              // 2. Search Input field
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.placeholder),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    ref.read(clientsSearchQueryProvider.notifier).state = val;
                  },
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16.spMin,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search clients by name or phone...',
                    hintStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 14.spMin,
                      color: AppColors.textBody.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w500,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: AppColors.textBody,
                      size: 20.r,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, size: 18.r),
                            onPressed: () {
                              _searchController.clear();
                              ref
                                  .read(clientsSearchQueryProvider.notifier)
                                  .state = '';
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                  ),
                ),
              ),
              24.verticalSpace,

              // 3. Dynamic content: Loading, Error, Empty, or List state
              Expanded(
                child: clientsAsyncValue.when(
                  data: (rawClients) {
                    if (rawClients.isEmpty) {
                      return Center(
                        child: CustomEmptyState(
                          title: 'No Clients Registered Yet',
                          subtitle:
                              'Create records and store body measurements easily.',
                          imageWidget: Container(
                            width: 150.r,
                            height: 150.r,
                            padding: EdgeInsets.all(20.r),
                            decoration: BoxDecoration(
                              color: AppColors.placeholder.withValues(alpha: 0.3),
                              shape: BoxShape.circle,
                            ),
                            child: Image.asset(
                              AppIcons.measuringTape,
                              width: 100.r,
                              height: 100.r,
                              fit: BoxFit.contain,
                            ),
                          ),
                          buttonText: 'Add Client Record',
                          onButtonPressed: () {
                            context.pushNamed(AppRoute.addClient.name);
                          },
                        ),
                      );
                    }

                    if (filteredClients.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off_outlined,
                              size: 64.r,
                              color: AppColors.textBody.withValues(alpha: 0.4),
                            ),
                            16.verticalSpace,
                            CustomText(
                              'No matching clients found',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 18.spMin,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            8.verticalSpace,
                            CustomText(
                              'Try checking spelling or phone digits.',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14.spMin,
                                color: AppColors.textBody,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      itemCount: filteredClients.length,
                      separatorBuilder: (context, index) => 12.verticalSpace,
                      itemBuilder: (context, index) {
                        final client = filteredClients[index];
                        final initials = _getInitials(client.fullName);
                        final avatarColor = _getAvatarColor(client.fullName);
                        final avatarTextColor =
                            _getAvatarTextColor(client.fullName);

                        return Container(
                          decoration: BoxDecoration(
                            color: AppColors.surfaceWhite,
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(
                              color: AppColors.placeholder.withValues(
                                alpha: 0.8,
                              ),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16.r),
                              onTap: () {
                                context.pushNamed(
                                  AppRoute.clientDetails.name,
                                  extra: client,
                                );
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 16.h,
                                ),
                                child: Row(
                                  children: [
                                    // Circular image/initials avatar
                                    Container(
                                      width: 48.r,
                                      height: 48.r,
                                      decoration: BoxDecoration(
                                        color: avatarColor,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.black.withValues(
                                            alpha: 0.05,
                                          ),
                                          width: 0.5.w,
                                        ),
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      child: client.photoUrl != null
                                          ? Image.network(
                                              client.photoUrl!,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Center(
                                                  child: CustomText(
                                                    initials,
                                                    style: GoogleFonts
                                                        .plusJakartaSans(
                                                      fontSize: 16.spMin,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: avatarTextColor,
                                                    ),
                                                  ),
                                                );
                                              },
                                              loadingBuilder: (context, child,
                                                  loadingProgress) {
                                                if (loadingProgress == null) {
                                                  return child;
                                                }
                                                return const Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    color: AppColors.primary,
                                                  ),
                                                );
                                              },
                                            )
                                          : Center(
                                              child: CustomText(
                                                initials,
                                                style: GoogleFonts
                                                    .plusJakartaSans(
                                                  fontSize: 16.spMin,
                                                  fontWeight: FontWeight.bold,
                                                  color: avatarTextColor,
                                                ),
                                              ),
                                            ),
                                    ),
                                    16.horizontalSpace,

                                    // Client details
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          CustomText(
                                            client.fullName,
                                            style: GoogleFonts.playfairDisplay(
                                              fontSize: 18.spMin,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                          4.verticalSpace,
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.phone_outlined,
                                                size: 14.r,
                                                color: AppColors.textBody,
                                              ),
                                              6.horizontalSpace,
                                              CustomText(
                                                client.phoneNumber ??
                                                    'No phone number',
                                                style:
                                                    GoogleFonts.plusJakartaSans(
                                                  fontSize: 13.spMin,
                                                  color: AppColors.textBody,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Gender Badge
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 10.w,
                                        vertical: 6.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: client.gender.toLowerCase() ==
                                                'male'
                                            ? AppColors.primary.withValues(
                                                alpha: 0.08,
                                              )
                                            : Colors.pink.withValues(
                                                alpha: 0.08,
                                              ),
                                        borderRadius:
                                            BorderRadius.circular(20.r),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            client.gender.toLowerCase() ==
                                                    'male'
                                                ? Icons.male
                                                : Icons.female,
                                            size: 14.r,
                                            color: client.gender.toLowerCase() ==
                                                    'male'
                                                ? AppColors.primary
                                                : Colors.pink[400],
                                          ),
                                          4.horizontalSpace,
                                          CustomText(
                                            client.gender[0].toUpperCase() +
                                                client.gender.substring(1),
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 12.spMin,
                                              fontWeight: FontWeight.bold,
                                              color: client.gender.toLowerCase() ==
                                                      'male'
                                                  ? AppColors.primary
                                                  : Colors.pink[400],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    8.horizontalSpace,
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 14.r,
                                      color: AppColors.textBody
                                          .withValues(alpha: 0.5),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  ),
                  error: (err, stack) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48.r,
                          color: AppColors.notification,
                        ),
                        16.verticalSpace,
                        CustomText(
                          'Error loading clients',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16.spMin,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        8.verticalSpace,
                        CustomText(
                          err.toString(),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.spMin,
                            color: AppColors.textBody,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
