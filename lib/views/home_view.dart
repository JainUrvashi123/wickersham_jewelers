import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/quote_viewmodel.dart';
import 'quotes_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:marquee/marquee.dart';
import '../services/metal_service.dart';
import 'admin_enquiries_view.dart';
class HomeView extends StatefulWidget {

  final Function(int)? onNavigate;
  const HomeView({Key? key, this.onNavigate}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  bool _isLoadingProfile = true;
  String? _cadGalleryName;
  String? _cadGalleryStatus;
  
  Map<String, dynamic>? _metalPrices;
  bool _isLoadingMetal = true;
  bool _showMetalPrices = true;

  bool get _isAdmin {
    final auth = context.read<AuthViewModel>();
    return auth.user?.userType == '1';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchProfile();
      _fetchMetalPrices();
    });
  }

  Future<void> _fetchProfile() async {
    final auth = context.read<AuthViewModel>();
    final profile = await auth.fetchProfile();
    if (mounted) {
      setState(() {
        _cadGalleryName = profile?.cadGalleryName;
        _cadGalleryStatus = profile?.cadGalleryStatus;
        _isLoadingProfile = false;
      });
    }
  }

  Future<void> _fetchMetalPrices() async {
    final metalService = MetalService();
    final prices = await metalService.getMetalPrices();
    if (mounted) {
      setState(() {
        _metalPrices = prices;
        _isLoadingMetal = false;
      });
    }
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _showMetalPrices = true;
      _isLoadingMetal = true;
    });
    await Future.wait([
      _fetchProfile(),
      _fetchMetalPrices(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = _isAdmin;
    if (isAdmin) {
      return Scaffold(
        backgroundColor: const Color(0xFFFCF8F5),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              children: [
                if (!_isLoadingMetal && _metalPrices != null && _showMetalPrices) ...[
                  _buildMetalPricesBar(),
                  const SizedBox(height: 12),
                ],
                SizedBox(
                  height: 150,
                  child: _buildWelcomeBanner(),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: _buildDashboardGrid(context),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFCF8F5),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          color: const Color(0xFF000000),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                children: [
                  if (!_isLoadingMetal && _metalPrices != null && _showMetalPrices)
                    _buildMetalPricesBar(),
                  SizedBox(
                    height: 150,
                    child: _buildWelcomeBanner(),
                  ),
                  const SizedBox(height: 16),
                  _buildDashboardGrid(context),
                  if (!_isAdmin) ...[
                    const SizedBox(height: 16),
                    _buildContactCard(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetalPricesBar() {
    return Container(
      height: 40,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.08), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRect(
              child: Marquee(
                text: 'Gold: \$${_metalPrices!['gold']}   |   Platinum: \$${_metalPrices!['platinum']}   |   Silver: \$${_metalPrices!['silver']}',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF000000),
                  fontSize: 13,
                ),
                scrollAxis: Axis.horizontal,
                crossAxisAlignment: CrossAxisAlignment.center,
                blankSpace: 50.0,
                velocity: 30.0,
                startPadding: 10.0,
                accelerationDuration: const Duration(seconds: 1),
                accelerationCurve: Curves.linear,
                decelerationDuration: const Duration(milliseconds: 500),
                decelerationCurve: Curves.easeOut,
              ),
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _showMetalPrices = false;
                });
              },
              child: const Icon(Icons.close, size: 18, color: Color(0xFF000000)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: const DecorationImage(
          image: AssetImage('assets/images/Custom_Banner.jpeg'),
          fit: BoxFit.cover,
        ),
      ),
      // child: Column(
      //   crossAxisAlignment: CrossAxisAlignment.start,
      //   mainAxisAlignment: MainAxisAlignment.center,
      //   children: [
      //     Text(
      //       'Welcome back!',
      //       style: GoogleFonts.poppins(
      //         fontSize: 24,
      //         fontWeight: FontWeight.w600,
      //         color: Colors.white,
      //       ),
      //     ),
      //     const SizedBox(height: 8),
      //     Text(
      //       'Explore, manage &\ngrow your business',
      //       style: GoogleFonts.poppins(
      //         fontSize: 14,
      //         fontWeight: FontWeight.w400,
      //         color: Colors.white.withOpacity(0.9),
      //       ),
      //     ),
      //   ],
      // ),
    );
  }

  Widget _buildDashboardGrid(BuildContext context) {
    final isAdmin = _isAdmin;
    return Consumer<QuoteViewModel>(
      builder: (context, quoteVM, _) {
        if (isAdmin) {
          final allDesigns = quoteVM.adminDesigns;
          final allCount = allDesigns.length;
          final quoteCount = allDesigns.where((q) => q.status.toLowerCase() == 'quote').length;
          final orderCount = allDesigns.where((q) => q.status.toLowerCase() == 'order').length;
          final completedCount = allDesigns.where((q) => q.status.toLowerCase() == 'completed').length;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _buildAdminDashboardItem(
                  context,
                  title: 'All Enquiries',
                  subtitle: 'View all design enquiries and messages',
                  icon: Icons.admin_panel_settings_outlined,
                  onTap: () => Navigator.pushNamed(context, '/admin_enquiries'),
                  badgeCount: allCount,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _buildAdminDashboardItem(
                  context,
                  title: 'Quotes',
                  subtitle: 'Manage price quote requests from clients',
                  icon: Icons.format_quote_outlined,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminEnquiriesView(initialStatus: 'Quote'),
                    ),
                  ),
                  badgeCount: quoteCount,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _buildAdminDashboardItem(
                  context,
                  title: 'Orders',
                  subtitle: 'Manage ongoing custom order production',
                  icon: Icons.shopping_bag_outlined,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminEnquiriesView(initialStatus: 'Order'),
                    ),
                  ),
                  badgeCount: orderCount,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _buildAdminDashboardItem(
                  context,
                  title: 'Completed',
                  subtitle: 'View completed enquiries and orders archive',
                  icon: Icons.assignment_turned_in_outlined,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminEnquiriesView(initialStatus: 'Completed'),
                    ),
                  ),
                  badgeCount: completedCount,
                ),
              ),
            ],
          );
        }

        // Return user dashboard grid
        final userQuotesUnread = quoteVM.unreadQuotesCount;
        return GridView.count(
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.65,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildDashboardItem(
              context,
              title: 'Product',
              subtitle: 'Manage your\nProduct',
              icon: Icons.inventory_2_outlined,
              iconColor: const Color(0xFF000000),
              bgColor: const Color(0xFFF5F5F5),
              onTap: () {
                if (widget.onNavigate != null) {
                  widget.onNavigate!(1);
                } else {
                  Navigator.pushNamed(context, '/jewelry');
                }
              },
            ),
            _buildDashboardItem(
              context,
              title: 'New Arrival',
              subtitle: 'Check out the\nlatest items',
              icon: Icons.work_outline,
              iconColor: const Color(0xFF333333),
              bgColor: const Color(0xFFF5F5F5),
              onTap: () => Navigator.pushNamed(context, '/new_arrival'),
            ),
            _buildDashboardItem(
              context,
              title: 'Custom',
              subtitle: 'Creat your\nown design',
              icon: Icons.diamond_outlined,
              iconColor: const Color(0xFF333333),
              bgColor: const Color(0xFFF5F5F5),
              onTap: () {
                if (widget.onNavigate != null) {
                  widget.onNavigate!(2);
                } else {
                  Navigator.pushNamed(context, '/custom_design');
                }
              },
            ),
            _buildDashboardItem(
              context,
              title: 'My Quotes',
              subtitle: 'View and manage\nyour quotes',
              icon: Icons.format_quote_outlined,
              iconColor: const Color(0xFF333333),
              bgColor: const Color(0xFFF5F5F5),
              onTap: () => Navigator.pushNamed(context, '/quotes'),
              badgeCount: userQuotesUnread,
            ),
            _buildDashboardItem(
              context,
              title: 'My orders',
              subtitle: 'Track and manage\nyour orders',
              icon: Icons.shopping_bag_outlined,
              iconColor: const Color(0xFF333333),
              bgColor: const Color(0xFFF5F5F5),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const QuotesView(type: 'my_orders'),
                  ),
                );
              },
            ),
            _buildDashboardItem(
              context,
              title: 'Completed\nOrders',
              subtitle: 'View your\ncompleted orders',
              icon: Icons.assignment_turned_in_outlined,
              iconColor: const Color(0xFF333333),
              bgColor: const Color(0xFFF5F5F5),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const QuotesView(type: 'completed_orders'),
                  ),
                );
              },
            ),
            if (!isAdmin &&
                !_isLoadingProfile &&
                _cadGalleryName != null &&
                _cadGalleryName!.isNotEmpty &&
                _cadGalleryStatus == '1')
              _buildDashboardItem(
                context,
                title: 'My CAD',
                subtitle: 'View your\nCAD designs',
                icon: Icons.architecture_outlined,
                iconColor: const Color(0xFF000000),
                bgColor: const Color(0xFFF5F5F5),
                onTap: () => Navigator.pushNamed(context, '/my_cad'),
              ),
            if (!isAdmin &&
                !_isLoadingProfile &&
                _cadGalleryName != null &&
                _cadGalleryName!.isNotEmpty &&
                _cadGalleryStatus == '1')
              _buildDashboardItem(
                context,
                title: 'My Gallery',
                subtitle: 'View your\ngallery',
                icon: Icons.photo_library_outlined,
                iconColor: const Color(0xFF333333),
                bgColor: const Color(0xFFF5F5F5),
                onTap: () => Navigator.pushNamed(context, '/gallery'),
              ),
          ],
        );
      },
    );
  }

  Widget _buildAdminDashboardItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    int badgeCount = 0,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.08), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F5F5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF000000),
                  size: 24,
                ),
              ),
              if (badgeCount > 0)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF000000),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Center(
                      child: Text(
                        '$badgeCount',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          title: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF000000),
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              subtitle,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.black26,
            size: 16,
          ),
          onTap: onTap,
        ),
      ),
    );
  }

    Widget _buildDashboardItem(
      BuildContext context, {
      required String title,
      required String subtitle,
      required IconData icon,
      required Color iconColor,
      required Color bgColor,
      required VoidCallback onTap,
      int badgeCount = 0,
    }) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: bgColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: iconColor, size: 24),
                  ),
                  if (badgeCount > 0)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Center(
                          child: Text(
                            '$badgeCount',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 9,
                        fontWeight: FontWeight.w400,
                        color: Colors.black54,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.chevron_right, color: Colors.white, size: 16),
              ),
            ],
          ),
        ),
      );
  }

  Widget _buildContactCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFF7F8FA),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.headset_mic_outlined, color: Color(0xFF2C3E50), size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Wickersham Jewelers',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'jeff@wickershamjewelry.com',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.black54,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () async {
                  final Uri url = Uri.parse('mailto:jeff@wickershamjewelry.com');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.email_outlined, color: Color(0xFF333333), size: 20),
                ),
              ),

            ],
          ),
        ],
      ),
    );
  }
}
