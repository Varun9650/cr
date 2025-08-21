import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'logistics/viewmodels/logistics_view_model.dart';
import 'logistics/widgets/logistics_widgets.dart';

class LogisticsScreen extends StatefulWidget {
  const LogisticsScreen({Key? key}) : super(key: key);

  @override
  State<LogisticsScreen> createState() => _LogisticsScreenState();
}

class _LogisticsScreenState extends State<LogisticsScreen>
    with TickerProviderStateMixin {
  late LogisticsViewModel _viewModel;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _viewModel = LogisticsViewModel();

    // Initialize animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _viewModel.addListener(_onViewModelChanged);
    _viewModel.fetchLogisticsData();
  }

  void _onViewModelChanged() {
    if (!_viewModel.isLoading && _viewModel.logisticsData != null) {
      _fadeController.forward();
      _slideController.forward();
    }
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<LogisticsViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            backgroundColor: const Color(0xFFF8FAFC),
            body: RefreshIndicator(
              onRefresh: viewModel.refresh,
              color: Colors.blue[600],
              backgroundColor: Colors.white,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // Custom App Bar
                  SliverAppBar(
                    expandedHeight: 120,
                    floating: false,
                    pinned: true,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue[600]!,
                              Colors.blue[800]!,
                              Colors.indigo[700]!,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.local_shipping,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 3),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          'Tournament Logistics',
                                          style: GoogleFonts.poppins(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Track your Logistics status',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: Colors.white.withOpacity(0.9),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Content
                  SliverPadding(
                    padding: const EdgeInsets.all(20),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        if (viewModel.isLoading)
                          LogisticsWidgets.buildLoadingCard()
                        else if (viewModel.hasError)
                          LogisticsWidgets.buildErrorCard(
                            errorMessage: viewModel.getFormattedErrorMessage(),
                            onRetry: viewModel.retry,
                          )
                        else if (viewModel.isLoaded)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Venue Information (Always shown)
                              Container(
                                padding: const EdgeInsets.all(20),
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    LogisticsWidgets.buildSectionHeader(
                                      title: 'Venue Information',
                                      icon: Icons.location_on,
                                      color: Colors.red[600]!,
                                      fadeAnimation: _fadeAnimation,
                                    ),
                                    const SizedBox(height: 2),
                                    LogisticsWidgets.buildInfoCard(
                                      title: 'Venue Address',
                                      value: '''LSBI Badminton Arena
                                          Behind Meadows Soc, 9/10, E Ave Rd,
                                          Nr. Bramha Sun City, Digambar Nagar,
                                          Wadgaon Sheri, Pune 411014.''',
                                      icon: Icons.place,
                                      color: Colors.red[600],
                                      index: 0,
                                      fadeAnimation: _fadeAnimation,
                                      slideAnimation: _slideAnimation,
                                    ),
                                  ],
                                ),
                              ),

                              // Status Overview (Always shown when data exists)
                              if (viewModel.logisticsData != null)
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  // margin: const EdgeInsets.only(bottom: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  // child: IntrinsicHeight(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Flexible(
                                      //   child:
                                      LogisticsWidgets.buildSectionHeader(
                                        title: 'Status Overview',
                                        icon: Icons.check_circle_outline,
                                        color: Colors.green[600]!,
                                        fadeAnimation: _fadeAnimation,
                                      ),
                                      // ),
                                      // const SizedBox(height: 8),
                                      LogisticsWidgets.buildStatusCard(
                                        title: 'Pickup Arranged',
                                        status:
                                            viewModel.logisticsData!.pickUp ??
                                                false,
                                        icon: Icons.local_shipping,
                                        color: Colors.blue[600]!,
                                        index: 0,
                                        fadeAnimation: _fadeAnimation,
                                        slideAnimation: _slideAnimation,
                                      ),
                                      // const SizedBox(height: 8),
                                      LogisticsWidgets.buildStatusCard(
                                        title: 'T-Shirt Received',
                                        status: viewModel.logisticsData!
                                                .tshirtReceived ??
                                            false,
                                        icon: Icons.checkroom,
                                        color: Colors.green[600]!,
                                        index: 1,
                                        fadeAnimation: _fadeAnimation,
                                        slideAnimation: _slideAnimation,
                                      ),
                                      // const SizedBox(height: 8),
                                      LogisticsWidgets.buildStatusCard(
                                        title: 'Certificate Received',
                                        status: viewModel
                                                .logisticsData!.certificate ??
                                            false,
                                        icon: Icons.verified,
                                        color: Colors.orange[600]!,
                                        index: 2,
                                        fadeAnimation: _fadeAnimation,
                                        slideAnimation: _slideAnimation,
                                      ),
                                      // const SizedBox(height: 8),
                                      LogisticsWidgets.buildStatusCard(
                                        title: 'Payment Received',
                                        status: viewModel.logisticsData!
                                                .paymentReceived ??
                                            false,
                                        icon: Icons.payment,
                                        color: Colors.purple[600]!,
                                        index: 3,
                                        fadeAnimation: _fadeAnimation,
                                        slideAnimation: _slideAnimation,
                                      ),
                                    ],
                                  ),
                                  // ),
                                ),

                              const SizedBox(height: 200),
                              // Pickup Information (Always shown when data exists)
                              if (viewModel.logisticsData != null)
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  // margin: const EdgeInsets.only(bottom: 20),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: IntrinsicHeight(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Flexible(
                                          child: LogisticsWidgets
                                              .buildSectionHeader(
                                            title: 'Pickup Information',
                                            icon: Icons.local_shipping,
                                            color: Colors.blue[600]!,
                                            fadeAnimation: _fadeAnimation,
                                          ),
                                        ),
                                        // const SizedBox(height: 12),
                                        LogisticsWidgets.buildInfoCard(
                                          title: 'Pickup Address',
                                          value: viewModel.logisticsData!
                                                  .pickupAddress ??
                                              'Data not found for this field',
                                          icon: Icons.location_on,
                                          color: Colors.blue[600],
                                          index: 0,
                                          fadeAnimation: _fadeAnimation,
                                          slideAnimation: _slideAnimation,
                                        ),
                                        const SizedBox(height: 16),
                                        LogisticsWidgets.buildInfoCard(
                                          title: 'Coordinates',
                                          value: (viewModel.logisticsData!
                                                          .pickupLatitude !=
                                                      null &&
                                                  viewModel.logisticsData!
                                                          .pickupLongitude !=
                                                      null)
                                              ? '${viewModel.logisticsData!.pickupLatitude}, ${viewModel.logisticsData!.pickupLongitude}'
                                              : 'Data not found for this field',
                                          icon: Icons.gps_fixed,
                                          color: Colors.green[600],
                                          index: 1,
                                          fadeAnimation: _fadeAnimation,
                                          slideAnimation: _slideAnimation,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 80),
                              // Payment Information (Always shown when data exists)
                              if (viewModel.logisticsData != null)
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  margin: const EdgeInsets.only(bottom: 20),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: IntrinsicHeight(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Flexible(
                                          child: LogisticsWidgets
                                              .buildSectionHeader(
                                            title: 'Payment Information',
                                            icon: Icons.payment,
                                            color: Colors.purple[600]!,
                                            fadeAnimation: _fadeAnimation,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        LogisticsWidgets.buildInfoCard(
                                          title: 'Payment Mode',
                                          value: viewModel.logisticsData!
                                                  .modeOfPayment ??
                                              'Data not found for this field',
                                          icon: Icons.payment,
                                          color: Colors.purple[600],
                                          index: 0,
                                          fadeAnimation: _fadeAnimation,
                                          slideAnimation: _slideAnimation,
                                        ),
                                        const SizedBox(height: 8),
                                        LogisticsWidgets.buildInfoCard(
                                          title: 'Transaction ID',
                                          value: viewModel.logisticsData!
                                                  .transactionId ??
                                              'Data not found for this field',
                                          icon: Icons.receipt,
                                          color: Colors.indigo[600],
                                          index: 1,
                                          fadeAnimation: _fadeAnimation,
                                          slideAnimation: _slideAnimation,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 30),
                              // Tournament Information (Always shown when data exists)
                              // if (viewModel.logisticsData != null)
                              //   Container(
                              //     padding: const EdgeInsets.all(20),
                              //     margin: const EdgeInsets.only(bottom: 20),
                              //     decoration: BoxDecoration(
                              //       color: Colors.white,
                              //       borderRadius: BorderRadius.circular(16),
                              //       boxShadow: [
                              //         BoxShadow(
                              //           color: Colors.black.withOpacity(0.05),
                              //           blurRadius: 10,
                              //           offset: const Offset(0, 4),
                              //         ),
                              //       ],
                              //     ),
                              //     child: IntrinsicHeight(
                              //       child: Column(
                              //         crossAxisAlignment:
                              //             CrossAxisAlignment.start,
                              //         children: [
                              //           Flexible(
                              //             child: LogisticsWidgets
                              //                 .buildSectionHeader(
                              //               title: 'Tournament Information',
                              //               icon: Icons.sports_cricket,
                              //               color: Colors.orange[600]!,
                              //               fadeAnimation: _fadeAnimation,
                              //             ),
                              //           ),
                              //           const SizedBox(height: 12),
                              //           LogisticsWidgets.buildInfoCard(
                              //             title: 'Tournament ID',
                              //             value: viewModel.logisticsData!.tourId
                              //                     ?.toString() ??
                              //                 'Data not found for this field',
                              //             icon: Icons.tag,
                              //             color: Colors.orange[600],
                              //             index: 0,
                              //             fadeAnimation: _fadeAnimation,
                              //             slideAnimation: _slideAnimation,
                              //           ),
                              //         ],
                              //       ),
                              //     ),
                              //   ),

                              // Bottom spacing
                              const SizedBox(height: 20),
                            ],
                          )
                        else
                          // Show "Data not uploaded" message
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.cloud_upload_outlined,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Data Not Uploaded',
                                  style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[700],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tournament logistics information has not been uploaded yet.',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
