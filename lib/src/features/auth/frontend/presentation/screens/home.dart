import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sewsafe_mobile/src/core/constants/app_colors.dart';
import 'package:sewsafe_mobile/src/core/constants/app_icons.dart';
import 'package:sewsafe_mobile/src/core/route/app_route.dart';
import 'package:sewsafe_mobile/src/core/widgets/custom_empty_state.dart';
import 'package:sewsafe_mobile/src/core/widgets/custom_svg.dart';
import 'package:sewsafe_mobile/src/core/widgets/custom_text.dart';
import 'package:sewsafe_mobile/src/core/widgets/custom_textform_field.dart';
import 'package:sewsafe_mobile/src/features/auth/backend/data/auth_repository.dart';
import 'package:sewsafe_mobile/src/features/customer_management/domain/entities/client.dart';
import 'package:sewsafe_mobile/src/features/customer_management/presentation/controller/client_controller.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _selectedStatusFilter = 'All';
  String _homeSearchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning,';
    } else if (hour < 17) {
      return 'Good afternoon,';
    } else {
      return 'Good evening,';
    }
  }

  /// Generates mock order information dynamically based on saved client records
  List<Map<String, dynamic>> _generateMockOrders(List<Client> clients) {
    final List<Map<String, dynamic>> mockOrders = [];
    final List<String> statuses = ['Ready', 'Pending', 'Sewing', 'Draft'];
    
    for (int i = 0; i < clients.length; i++) {
      final client = clients[i];
      final status = statuses[i % statuses.length];
      
      String styleName = '';
      if (client.gender.toLowerCase() == 'male') {
        styleName = i % 2 == 0 ? 'Senator Suit (Navy)' : 'Kaftan (White)';
      } else {
        styleName = i % 2 == 0 ? 'Lace Aso Ebi' : 'Ankara Gown';
      }

      if (status == 'Draft') {
        styleName = 'Select to complete details...';
      }

      mockOrders.add({
        'client': client,
        'status': status,
        'styleName': styleName,
        'phone': client.phoneNumber ?? '--',
      });
    }
    return mockOrders;
  }

  @override
  Widget build(BuildContext context) {
    // 1. Get authenticated user
    final authRepository = ref.watch(authRepositoryProvider);
    final user = authRepository.currentUser;
    final email = user?.email ?? '';
    final String displayName = email.isNotEmpty
        ? email
              .split('@')
              .first
              .split('.')
              .map((s) => s.isNotEmpty ? s[0].toUpperCase() + s.substring(1) : '')
              .join(' ')
        : 'Esther';

    // 2. Watch clients list
    final clientsAsyncValue = ref.watch(clientsListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: clientsAsyncValue.when(
          data: (clients) {
            if (clients.isEmpty) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 20.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Row
                    _buildHeaderRow(displayName),
                    Expanded(
                      child: Center(
                        child: CustomEmptyState(
                          title: 'No clients or orders yet',
                          titleHeight: 1.2,
                          subtitleHeight: 1.4,
                          imageWidget: Container(
                            width: 180.r,
                            height: 180.r,
                            padding: EdgeInsets.all(24.r),
                            decoration: BoxDecoration(
                              color: AppColors.placeholder.withValues(alpha: 0.3),
                              shape: BoxShape.circle,
                            ),
                            child: Image.asset(
                              AppIcons.measuringTape,
                              width: 130.r,
                              height: 130.r,
                              fit: BoxFit.contain,
                            ),
                          ),
                          buttonText: 'Add Your First Client',
                          onButtonPressed: () {
                            context.pushNamed(AppRoute.addClient.name);
                          },
                          subtitle:
                              'Your journey to never losing a measurement starts here.',
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            // Generate mock active orders based on actual database clients
            final allOrders = _generateMockOrders(clients);

            // Filter active orders based on selected status pill and search bar query
            final filteredOrders = allOrders.where((order) {
              final client = order['client'] as Client;
              final status = order['status'] as String;
              
              // Status Pill filter
              if (_selectedStatusFilter != 'All') {
                if (_selectedStatusFilter == 'To Sew' && status != 'Sewing') {
                  return false;
                }
                if (_selectedStatusFilter == 'Pending' && status != 'Pending') {
                  return false;
                }
                if (_selectedStatusFilter == 'Ready' && status != 'Ready') {
                  return false;
                }
              }

              // Search query filter
              if (_homeSearchQuery.isNotEmpty) {
                final query = _homeSearchQuery.toLowerCase();
                final nameMatches = client.fullName.toLowerCase().contains(query);
                final phoneMatches = client.phoneNumber?.toLowerCase().contains(query) ?? false;
                final styleMatches = order['styleName'].toString().toLowerCase().contains(query);
                return nameMatches || phoneMatches || styleMatches;
              }

              return true;
            }).toList();

            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(clientsListProvider);
              },
              color: AppColors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 20.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Header row
                    _buildHeaderRow(displayName),
                    24.verticalSpace,

                    // 2. Global Search Bar
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
                      child: CustomTextField(
                        controller: _searchController,
                        onChanged: (val) {
                          setState(() {
                            _homeSearchQuery = val;
                          });
                        },
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16.spMin,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                        hintText: 'Search clients or measurements...',
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
                                  setState(() {
                                    _homeSearchQuery = '';
                                  });
                                },
                              )
                            : null,
                        filled: false,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 14.h,
                        ),
                      ),
                    ),
                    20.verticalSpace,

                    // 3. Status Filters (Horizontal Pills)
                    SizedBox(
                      height: 38.h,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        children: [
                          _buildStatusPill('All'),
                          12.horizontalSpace,
                          _buildStatusPill('Pending', badgeColor: AppColors.notification),
                          12.horizontalSpace,
                          _buildStatusPill('Ready', badgeColor: AppColors.ready),
                          12.horizontalSpace,
                          _buildStatusPill('To Sew', labelText: 'To Sew', badgeColor: AppColors.notification),
                        ],
                      ),
                    ),
                    28.verticalSpace,

                    // 4. Active Orders List Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomText(
                          'Active Orders',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18.spMin,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: CustomText('View All Orders coming soon!', color: Colors.white),
                                backgroundColor: AppColors.primary,
                              ),
                            );
                          },
                          child: CustomText(
                            'View All',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.spMin,
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    16.verticalSpace,

                    // 5. Active Order Cards
                    filteredOrders.isEmpty
                        ? Padding(
                            padding: EdgeInsets.symmetric(vertical: 40.h),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.inventory_2_outlined,
                                    size: 48.r,
                                    color: AppColors.textBody.withValues(alpha: 0.5),
                                  ),
                                  12.verticalSpace,
                                  CustomText(
                                    'No active orders found matching filters.',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14.spMin,
                                      color: AppColors.textBody,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: filteredOrders.length,
                            separatorBuilder: (context, index) => 16.verticalSpace,
                            itemBuilder: (context, index) {
                              final order = filteredOrders[index];
                              final client = order['client'] as Client;
                              final status = order['status'] as String;
                              final styleName = order['styleName'] as String;
                              final phone = order['phone'] as String;

                              return _buildActiveOrderCard(
                                client: client,
                                status: status,
                                styleName: styleName,
                                phone: phone,
                              );
                            },
                          ),
                  ],
                ),
              ),
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (err, stack) => Center(
            child: CustomText(
              'Error loading dashboard: $err',
              style: GoogleFonts.plusJakartaSans(color: AppColors.notification),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderRow(String displayName) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 26.r,
          backgroundColor: AppColors.placeholder,
          backgroundImage: const NetworkImage(
            'https://avatars.githubusercontent.com/u/258787491?v=4',
          ), // Profile avatar
        ),
        12.horizontalSpace,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomText(
                _getGreeting(),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16.spMin,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
              2.verticalSpace,
              CustomText(
                displayName,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 24.spMin,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Badge(
          padding: EdgeInsets.zero,
          offset: const Offset(4, -4),
          backgroundColor: AppColors.notification,
          child: CustomSvg(
            AppIcons.notificationBell,
            width: 24.w,
            height: 32.h,
            color: AppColors.textBody,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusPill(String status, {String? labelText, Color? badgeColor}) {
    final isSelected = _selectedStatusFilter == status;
    final displayLabel = labelText ?? status;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStatusFilter = status;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.placeholder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomText(
              displayLabel,
              style: GoogleFonts.plusJakartaSans(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontSize: 14.spMin,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
            if (badgeColor != null) ...[
              8.horizontalSpace,
              Container(
                width: 6.r,
                height: 6.r,
                decoration: BoxDecoration(
                  color: badgeColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActiveOrderCard({
    required Client client,
    required String status,
    required String styleName,
    required String phone,
  }) {
    final isDraft = status == 'Draft';
    
    // Status text color styling
    Color statusColor = AppColors.textBody;
    if (status == 'Ready') statusColor = AppColors.ready;
    if (status == 'Sewing') statusColor = Colors.orange[600]!;
    if (status == 'Pending') statusColor = Colors.blue[600]!;
    if (status == 'Draft') statusColor = AppColors.textBody.withValues(alpha: 0.6);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.placeholder.withValues(alpha: 0.8)),
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
            // Tapping on the active order routes directly to Client details profile
            context.pushNamed(AppRoute.clientDetails.name, extra: client);
          },
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Row(
              children: [
                // Left thumbnail image
                Container(
                  width: 56.r,
                  height: 56.r,
                  decoration: BoxDecoration(
                    color: AppColors.placeholder.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: client.photoUrl != null
                      ? Image.network(
                          client.photoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            isDraft ? Icons.edit_note : Icons.cut_outlined,
                            color: AppColors.primary,
                            size: 24.r,
                          ),
                        )
                      : Icon(
                          isDraft ? Icons.edit_note : Icons.cut_outlined,
                          color: AppColors.primary,
                          size: 24.r,
                        ),
                ),
                16.horizontalSpace,

                // Content block
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomText(
                            client.fullName,
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 17.spMin,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          CustomText(
                            status,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.spMin,
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      6.verticalSpace,
                      CustomText(
                        styleName,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.spMin,
                          color: AppColors.textBody,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      8.verticalSpace,
                      Row(
                        children: [
                          Icon(Icons.phone_outlined, size: 12.r, color: AppColors.textBody),
                          4.horizontalSpace,
                          CustomText(
                            phone,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.spMin,
                              color: AppColors.textBody,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                12.horizontalSpace,
                Icon(
                  isDraft ? Icons.edit : Icons.arrow_forward_ios,
                  size: 16.r,
                  color: AppColors.textBody.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
