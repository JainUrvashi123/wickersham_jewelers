import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_assets.dart';
import '../core/constants/app_colors.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/jewelry_viewmodel.dart';
import '../viewmodels/cart_viewmodel.dart';
import '../viewmodels/wishlist_viewmodel.dart';
import '../viewmodels/quote_viewmodel.dart';
import '../core/providers/global_loader_provider.dart';
import 'home_view.dart';
import 'jewelry_view.dart';
import 'custom_design_view.dart';
import 'contact_view.dart';

class MainLayoutView extends StatefulWidget {
  const MainLayoutView({Key? key}) : super(key: key);

  @override
  State<MainLayoutView> createState() => _MainLayoutViewState();
}

// class _MainLayoutViewState extends State<MainLayoutView> {
//   int _currentIndex = 0;
//
//   final List<Widget> _pages = [
//     const HomeView(),
//     const JewelryView(),
//     const Center(child: Text('Custom Design Coming Soon')),
//     const Center(child: Text('Contact Coming Soon')),
//     const Center(child: Text('Information Coming Soon')),
//   ];
//
//   void _onItemTapped(int index) {
//     setState(() {
//       _currentIndex = index;
//     });
//   }
//
//   void _showFilterBottomSheet(BuildContext context, JewelryViewModel vm) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.white,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//       ),
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setStateSync) {
//             return DraggableScrollableSheet(
//               initialChildSize: 0.8,
//               minChildSize: 0.5,
//               maxChildSize: 0.95,
//               expand: false,
//               builder: (context, scrollController) {
//                 return Column(
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                       decoration: BoxDecoration(
//                         border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text('Filters', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
//                           TextButton(
//                             onPressed: () {
//                               vm.clearFilters();
//                               Navigator.pop(context);
//                             },
//                             child: Text('CLEAR ALL', style: GoogleFonts.poppins(color: Colors.black)),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Expanded(
//                       child: vm.isLoadingFilters
//                           ? const Center(child: CircularProgressIndicator())
//                           : ListView(
//                               controller: scrollController,
//                               padding: const EdgeInsets.all(16),
//                               children: [
//                                 _buildFilterSection(
//                                   title: 'CATEGORIES',
//                                   items: vm.filterData?.categories ?? [],
//                                   selectedItems: vm.selectedCategories,
//                                   onToggle: (val) {
//                                     vm.toggleCategory(val);
//                                     setStateSync(() {});
//                                   },
//                                 ),
//                                 const Divider(),
//                                 _buildFilterSection(
//                                   title: 'METAL TYPE',
//                                   items: vm.filterData?.metalTypes ?? [],
//                                   selectedItems: vm.selectedMetals,
//                                   onToggle: (val) {
//                                     vm.toggleMetal(val);
//                                     setStateSync(() {});
//                                   },
//                                 ),
//                                 const Divider(),
//                                 _buildFilterSection(
//                                   title: 'STONE SHAPE',
//                                   items: vm.filterData?.stoneShapes ?? [],
//                                   selectedItems: vm.selectedShapes,
//                                   onToggle: (val) {
//                                     vm.toggleShape(val);
//                                     setStateSync(() {});
//                                   },
//                                 ),
//                                 const SizedBox(height: 80),
//                               ],
//                             ),
//                     ),
//                     Container(
//                       padding: const EdgeInsets.all(16),
//                       decoration: const BoxDecoration(
//                         color: Colors.white,
//                         boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))],
//                       ),
//                       child: SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: const AppColors.primaryButton,
//                             padding: const EdgeInsets.symmetric(vertical: 16),
//                           ),
//                           onPressed: () {
//                             vm.applyFilters();
//                             Navigator.pop(context);
//                           },
//                           child: Text('APPLY FILTERS', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
//                         ),
//                       ),
//                     ),
//                   ],
//                 );
//               },
//             );
//           },
//         );
//       },
//     );
//   }
//
//   Widget _buildFilterSection({
//     required String title,
//     required List<String> items,
//     required List<String> selectedItems,
//     required Function(String) onToggle,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold)),
//         const SizedBox(height: 8),
//         Wrap(
//           spacing: 8,
//           runSpacing: 0,
//           children: items.map((item) {
//             final isSelected = selectedItems.contains(item);
//             return FilterChip(
//               label: Text(item, style: GoogleFonts.poppins(fontSize: 12, color: isSelected ? Colors.white : Colors.black87)),
//               selected: isSelected,
//               onSelected: (_) => onToggle(item),
//               selectedColor: const AppColors.primaryButton,
//               checkmarkColor: Colors.white,
//             );
//           }).toList(),
//         ),
//       ],
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 2,
//         shadowColor: Colors.black12,
//         iconTheme: const IconThemeData(color: Colors.black),
//         title: Image.asset(AppAssets.logoEmail, height: 40, fit: BoxFit.contain),
//         centerTitle: true,
//         actions: [
//           if (_currentIndex == 1)
//             Consumer<JewelryViewModel>(
//               builder: (context, vm, _) {
//                 return IconButton(
//                   icon: const Icon(Icons.filter_list),
//                   onPressed: () => _showFilterBottomSheet(context, vm),
//                 );
//               },
//             ),
//           Consumer<AuthViewModel>(
//             builder: (context, authViewModel, child) {
//               final user = authViewModel.user;
//               if (user != null) {
//                 return Padding(
//                   padding: const EdgeInsets.only(right: 8.0),
//                   child: PopupMenuButton<String>(
//                     offset: const Offset(0, 45),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     color: Colors.white,
//                     elevation: 4,
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         const Icon(Icons.person_outline, color: Colors.black87),
//                         const SizedBox(width: 4),
//                         Text(
//                           '${user.userFirstname.isNotEmpty ? user.userFirstname[0].toUpperCase() : ''}${user.userLastname.isNotEmpty ? user.userLastname[0].toUpperCase() : ''}',
//                           style: GoogleFonts.poppins(
//                             color: Colors.black87,
//                             fontWeight: FontWeight.w500,
//                             fontSize: 14,
//                           ),
//                         ),
//                         const Icon(Icons.arrow_drop_down, color: Colors.black87),
//                       ],
//                     ),
//                     onSelected: (value) async {
//                       if (value == 'logout') {
//                         await authViewModel.logout();
//                       } else if (value == 'profile') {
//                         Navigator.pushNamed(context, '/profile');
//                       }
//                     },
//                     itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
//                       PopupMenuItem<String>(
//                         value: 'profile',
//                         child: Row(
//                           children: [
//                             const Icon(Icons.person_outline, size: 20, color: Colors.black54),
//                             const SizedBox(width: 12),
//                             Text(
//                               user.userFullname.isNotEmpty ? user.userFullname : '${user.userFirstname} ${user.userLastname}'.trim(),
//                               style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
//                             ),
//                           ],
//                         ),
//                       ),
//                       const PopupMenuDivider(),
//                       PopupMenuItem<String>(
//                         value: 'compare',
//                         child: Row(
//                           children: [
//                             const Icon(Icons.compare_arrows_outlined, size: 20, color: Colors.black54),
//                             const SizedBox(width: 12),
//                             Text('Compare', style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87)),
//                           ],
//                         ),
//                       ),
//                       PopupMenuItem<String>(
//                         value: 'quotes',
//                         child: Row(
//                           children: [
//                             const Icon(Icons.format_quote_outlined, size: 20, color: Colors.black54),
//                             const SizedBox(width: 12),
//                             Text('My Quotes', style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87)),
//                           ],
//                         ),
//                       ),
//                       const PopupMenuDivider(),
//                       PopupMenuItem<String>(
//                         value: 'logout',
//                         child: Row(
//                           children: [
//                             const Icon(Icons.logout_outlined, size: 20, color: Colors.black54),
//                             const SizedBox(width: 12),
//                             Text('Logout', style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87)),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               }
//               return IconButton(
//                 icon: const Icon(Icons.person_outline),
//                 onPressed: () {
//                   Navigator.pushNamed(context, '/login');
//                 },
//               );
//             },
//           ),
//           IconButton(
//             icon: const Icon(Icons.favorite_border_outlined),
//             onPressed: () {
//               Navigator.pushNamed(context, '/wishlist');
//             },
//           ),
//           IconButton(
//             icon: const Icon(Icons.shopping_bag_outlined),
//             onPressed: () {
//               Navigator.pushNamed(context, '/cart');
//             },
//           ),
//         ],
//       ),
//       body: IndexedStack(
//         index: _currentIndex,
//         children: _pages,
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _currentIndex,
//         onTap: _onItemTapped,
//         type: BottomNavigationBarType.fixed,
//         selectedItemColor: const AppColors.primaryButton,
//         unselectedItemColor: Colors.black54,
//         selectedLabelStyle: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
//         unselectedLabelStyle: GoogleFonts.poppins(fontSize: 11),
//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home_outlined),
//             activeIcon: Icon(Icons.home),
//             label: 'Home',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.diamond_outlined),
//             activeIcon: Icon(Icons.diamond),
//             label: 'Jewelry',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.design_services_outlined),
//             activeIcon: Icon(Icons.design_services),
//             label: 'Custom',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.contact_mail_outlined),
//             activeIcon: Icon(Icons.contact_mail),
//             label: 'Contact',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.info_outline),
//             activeIcon: Icon(Icons.info),
//             label: 'Info',
//           ),
//         ],
//       ),
//     );
//   }
class _MainLayoutViewState extends State<MainLayoutView> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthViewModel>(context, listen: false);
      final quoteVM = Provider.of<QuoteViewModel>(context, listen: false);
      if (auth.user != null) {
        if (auth.user!.userType == '1') {
          quoteVM.fetchAdminDesigns(auth);
        } else {
          quoteVM.fetchQuotes(auth);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthViewModel>(context);
    final user = auth.user;
    final isAdmin = user?.userType == '1';

    // Clamp _currentIndex to prevent index out of range when switching layout modes
    final int maxIndex = isAdmin ? 2 : 3;
    if (_currentIndex > maxIndex) {
      _currentIndex = maxIndex;
    }

    final double screenWidth = MediaQuery.of(context).size.width;
    String appBarTitle;
    if (_currentIndex == 0) {
      appBarTitle = 'Dashboard';
    } else if (_currentIndex == 1) {
      appBarTitle = 'Jewelry';
    } else if (_currentIndex == 2) {
      appBarTitle = isAdmin ? 'Contact' : 'Custom Design';
    } else {
      appBarTitle = 'Contact';
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawerEnableOpenDragGesture: _currentIndex == 0,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: _currentIndex == 0 ? 0 : null,
        centerTitle: screenWidth >= 1200,
        iconTheme: const IconThemeData(color: Colors.black87),
        leading: _currentIndex == 0
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _currentIndex = 0;
                  });
                },
              ),
        title: Text(
          appBarTitle,
          style: GoogleFonts.poppins(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.w400),
        ),
        actions: [
          if (_currentIndex == 0) ...[
            Consumer<QuoteViewModel>(
              builder: (context, quoteVM, _) {
                final count = isAdmin ? quoteVM.unreadAdminEnquiriesCount : quoteVM.unreadQuotesCount;
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined, size: 22),
                      onPressed: () {
                        if (isAdmin) {
                          Navigator.pushNamed(context, '/admin_enquiries');
                        } else {
                          Navigator.pushNamed(context, '/quotes');
                        }
                      },
                    ),
                    if (count > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 14,
                            minHeight: 14,
                          ),
                          child: Center(
                            child: Text(
                              '$count',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            _buildProfileButton(context),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.search, size: 22),
              onPressed: () => Navigator.pushNamed(context, '/search'),
            ),
            // Filter only shows on Jewelry Tab
            if (_currentIndex == 1)
              Consumer<JewelryViewModel>(
                builder: (context, vm, _) => IconButton(
                  icon: const Icon(Icons.tune_outlined, size: 22),
                  onPressed: () => _showFilterBottomSheet(context, vm),
                ),
              ),

            Consumer<CartViewModel>(
              builder: (context, cart, _) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.shopping_bag_outlined, size: 22),
                      onPressed: () => Navigator.pushNamed(context, '/cart'),
                    ),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${cart.totalItemCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            _buildProfileButton(context),
          ],
        ],
      ),
      drawer: _buildDrawer(context),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeView(onNavigate: (index) {
            if (isAdmin) {
              if (index == 2) return; // Custom is hidden/disabled for admin
              if (index == 3) {
                setState(() => _currentIndex = 2);
                return;
              }
            }
            setState(() => _currentIndex = index);
          }),
          const JewelryView(showAppBar: false),
          if (!isAdmin) const CustomDesignView(showAppBar: false),
          const ContactView(),
        ],
      ),
      bottomNavigationBar: isAdmin ? null : BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor:  AppColors.primaryButton,
        unselectedItemColor: Colors.black45,
        showUnselectedLabels: true,
        selectedLabelStyle: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          const BottomNavigationBarItem(icon: Icon(Icons.diamond_outlined), label: 'Jewelry'),
          if (!isAdmin) const BottomNavigationBarItem(icon: Icon(Icons.auto_awesome_outlined), label: 'Custom'),
          const BottomNavigationBarItem(icon: Icon(Icons.mail_outline), label: 'Contact'),
        ],
      ),
    );
  }


  Widget _buildProfileButton(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, auth, _) {
        final user = auth.user;
        if (user != null) {
          final firstLetter = user.userFirstname.isNotEmpty 
              ? user.userFirstname[0].toUpperCase() 
              : 'U';
          return Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/profile'),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primaryButton.withOpacity(0.1),
                child: Text(
                  firstLetter,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryButton,
                  ),
                ),
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }


  void _showFilterBottomSheet(BuildContext context, JewelryViewModel vm) {
    String formatPrice(double value) {
      final RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
      String str = value.round().toString();
      return str.replaceAllMapped(reg, (Match match) => '${match[1]},');
    }

    String formatPriceWithSpaces(double value) {
      final RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
      String str = value.round().toString();
      return str.replaceAllMapped(reg, (Match match) => '${match[1]} ');
    }

    double initialMin = 0.0;
    double initialMax = 150000000.0;
    if (vm.selectedPriceRange != null && vm.selectedPriceRange!.contains('-')) {
      final parts = vm.selectedPriceRange!.split('-');
      if (parts.length == 2) {
        initialMin = double.tryParse(parts[0]) ?? 0.0;
        initialMax = double.tryParse(parts[1]) ?? 150000000.0;
      }
    }

    final minController = TextEditingController(text: '\$ ${formatPrice(initialMin)}');
    final maxController = TextEditingController(text: '\$ ${formatPrice(initialMax)}');
    final FocusNode minFocus = FocusNode();
    final FocusNode maxFocus = FocusNode();

    StateSetter? sheetState;

    minFocus.addListener(() {
      if (!minFocus.hasFocus) {
        double currentMaxVal = 150000000.0;
        if (vm.selectedPriceRange != null && vm.selectedPriceRange!.contains('-')) {
          final parts = vm.selectedPriceRange!.split('-');
          if (parts.length == 2) {
            currentMaxVal = double.tryParse(parts[1]) ?? 150000000.0;
          }
        }
        final numericOnly = minController.text.replaceAll(RegExp(r'[^\d]'), '');
        double val = double.tryParse(numericOnly) ?? 0.0;
        if (val > currentMaxVal) val = currentMaxVal;
        if (val < 0.0) val = 0.0;
        vm.setPriceRangeValues(val, currentMaxVal);
        minController.text = '\$ ${formatPrice(val)}';
        if (sheetState != null) sheetState!(() {});
      }
    });

    maxFocus.addListener(() {
      if (!maxFocus.hasFocus) {
        double currentMinVal = 0.0;
        if (vm.selectedPriceRange != null && vm.selectedPriceRange!.contains('-')) {
          final parts = vm.selectedPriceRange!.split('-');
          if (parts.length == 2) {
            currentMinVal = double.tryParse(parts[0]) ?? 0.0;
          }
        }
        final numericOnly = maxController.text.replaceAll(RegExp(r'[^\d]'), '');
        double val = double.tryParse(numericOnly) ?? 150000000.0;
        if (val < currentMinVal) val = currentMinVal;
        if (val > 150000000.0) val = 150000000.0;
        vm.setPriceRangeValues(currentMinVal, val);
        maxController.text = '\$ ${formatPrice(val)}';
        if (sheetState != null) sheetState!(() {});
      }
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateSync) {
            sheetState = setStateSync;

            double currentMin = 0.0;
            double currentMax = 150000000.0;
            if (vm.selectedPriceRange != null && vm.selectedPriceRange!.contains('-')) {
              final parts = vm.selectedPriceRange!.split('-');
              if (parts.length == 2) {
                currentMin = double.tryParse(parts[0]) ?? 0.0;
                currentMax = double.tryParse(parts[1]) ?? 150000000.0;
              }
            }

            return DraggableScrollableSheet(
              initialChildSize: 0.8,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              expand: false,
              builder: (context, scrollController) {
                return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Filters', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                          TextButton(
                            onPressed: () {
                              vm.clearFilters();
                              minController.text = '\$ ${formatPrice(0.0)}';
                              maxController.text = '\$ ${formatPrice(150000000.0)}';
                              Navigator.pop(context);
                            },
                            child: Text('CLEAR ALL', style: GoogleFonts.poppins(color: Colors.black)),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: vm.isLoadingFilters
                          ? const Center(child: CircularProgressIndicator())
                          : ListView(
                              controller: scrollController,
                              padding: const EdgeInsets.all(16),
                              children: [
                                // Price Range Section
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'PRICE RANGE',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    SliderTheme(
                                      data: SliderTheme.of(context).copyWith(
                                        activeTrackColor: const Color(0xFFE5A354),
                                        inactiveTrackColor: const Color(0xFFE8E8E8),
                                        trackHeight: 4.0,
                                        thumbColor: const Color(0xFFE5A354),
                                        overlayColor: const Color(0xFFE5A354).withOpacity(0.2),
                                        activeTickMarkColor: Colors.transparent,
                                        inactiveTickMarkColor: Colors.transparent,
                                        rangeThumbShape: const RoundRangeSliderThumbShape(
                                          enabledThumbRadius: 10.0,
                                          elevation: 3.0,
                                        ),
                                        showValueIndicator: ShowValueIndicator.always,
                                        valueIndicatorColor: Colors.grey[600],
                                        valueIndicatorTextStyle: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                      child: RangeSlider(
                                        min: 0.0,
                                        max: 150000000.0,
                                        values: RangeValues(currentMin, currentMax),
                                        labels: RangeLabels(
                                          formatPriceWithSpaces(currentMin),
                                          formatPriceWithSpaces(currentMax),
                                        ),
                                        onChanged: (values) {
                                          vm.setPriceRangeValues(values.start, values.end);
                                          minController.text = '\$ ${formatPrice(values.start)}';
                                          maxController.text = '\$ ${formatPrice(values.end)}';
                                          setStateSync(() {});
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            controller: minController,
                                            focusNode: minFocus,
                                            keyboardType: TextInputType.number,
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(4),
                                                borderSide: BorderSide(color: Colors.grey[300]!),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(4),
                                                borderSide: BorderSide(color: Colors.grey[300]!),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(4),
                                                borderSide: const BorderSide(color: Color(0xFFE5A354)),
                                              ),
                                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                            ),
                                            style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
                                            onSubmitted: (val) {
                                              final numericOnly = val.replaceAll(RegExp(r'[^\d]'), '');
                                              double parsed = double.tryParse(numericOnly) ?? 0.0;
                                              if (parsed > currentMax) parsed = currentMax;
                                              if (parsed < 0.0) parsed = 0.0;
                                              vm.setPriceRangeValues(parsed, currentMax);
                                              minController.text = '\$ ${formatPrice(parsed)}';
                                              setStateSync(() {});
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: TextField(
                                            controller: maxController,
                                            focusNode: maxFocus,
                                            keyboardType: TextInputType.number,
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(4),
                                                borderSide: BorderSide(color: Colors.grey[300]!),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(4),
                                                borderSide: BorderSide(color: Colors.grey[300]!),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(4),
                                                borderSide: const BorderSide(color: Color(0xFFE5A354)),
                                              ),
                                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                            ),
                                            style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
                                            onSubmitted: (val) {
                                              final numericOnly = val.replaceAll(RegExp(r'[^\d]'), '');
                                              double parsed = double.tryParse(numericOnly) ?? 150000000.0;
                                              if (parsed < currentMin) parsed = currentMin;
                                              if (parsed > 150000000.0) parsed = 150000000.0;
                                              vm.setPriceRangeValues(currentMin, parsed);
                                              maxController.text = '\$ ${formatPrice(parsed)}';
                                              setStateSync(() {});
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    const Divider(),
                                  ],
                                ),
                                _buildFilterSection(
                                  title: 'CATEGORIES',
                                  items: vm.filterData?.categories ?? [],
                                  selectedItems: vm.selectedCategories,
                                  onToggle: (val) {
                                    vm.toggleCategory(val);
                                    setStateSync(() {});
                                  },
                                ),
                                const Divider(),
                                _buildFilterSection(
                                  title: 'METAL TYPE',
                                  items: vm.filterData?.metalTypes ?? [],
                                  selectedItems: vm.selectedMetals,
                                  onToggle: (val) {
                                    vm.toggleMetal(val);
                                    setStateSync(() {});
                                  },
                                ),
                                const SizedBox(height: 80),
                              ],
                            ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))],
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE5A354),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: () {
                            vm.applyFilters();
                            Navigator.pop(context);
                          },
                          child: Text('APPLY FILTERS', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  void _showDeleteAccountDialog(BuildContext context, AuthViewModel authViewModel) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Delete Account',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.red),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to delete your account?',
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Text(
                'This action is permanent and cannot be undone. All your data will be permanently removed.',
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.black54),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'CANCEL',
                style: GoogleFonts.poppins(color: Colors.grey, fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                Navigator.pop(context);
                final success = await authViewModel.deleteAccount();
                if (success) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Account deleted successfully')),
                    );
                    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                  }
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(authViewModel.errorMessage ?? 'Failed to delete account')),
                    );
                  }
                }
              },
              child: Text(
                'DELETE',
                style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context, AuthViewModel authViewModel) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(
            'Logout',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to log out of your account?',
            style: GoogleFonts.poppins(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'CANCEL',
                style: GoogleFonts.poppins(color: Colors.grey, fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryButton,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                final cartViewModel = Provider.of<CartViewModel>(context, listen: false);
                final wishlistViewModel = Provider.of<WishlistViewModel>(context, listen: false);
                final quoteViewModel = Provider.of<QuoteViewModel>(context, listen: false);
                final globalLoader = Provider.of<GlobalLoaderProvider>(context, listen: false);

                Navigator.pop(dialogContext);
                globalLoader.show();
                await authViewModel.logout();

                cartViewModel.clearCart();
                wishlistViewModel.clearWishlist();
                quoteViewModel.clearQuotes();
                globalLoader.hide();

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Logged out successfully')),
                  );
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                }
              },
              child: Text(
                'LOGOUT',
                style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterSection({
    required String title,
    required List<String> items,
    required List<String> selectedItems,
    required Function(String) onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 0,
          children: items.map((item) {
            final isSelected = selectedItems.contains(item);
            return FilterChip(
              label: Text(item, style: GoogleFonts.poppins(fontSize: 12, color: isSelected ? Colors.white : Colors.black87)),
              selected: isSelected,
              onSelected: (_) => onToggle(item),
              selectedColor: AppColors.primaryButton,
              checkmarkColor: Colors.white,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(24)),
      ),
      child: Consumer<AuthViewModel>(
        builder: (context, auth, _) {
          final user = auth.user;
          final isAdmin = user?.userType == '1';

          final userName = user != null 
              ? (user.userFullname.isNotEmpty 
                  ? user.userFullname 
                  : '${user.userFirstname} ${user.userLastname}'.trim()) 
              : 'User';
              
          final firstLetter = user != null 
              ? (user.userFirstname.isNotEmpty ? user.userFirstname[0].toUpperCase() : 'U') 
              : 'U';

          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 60, bottom: 30, left: 24, right: 24),
                decoration: const BoxDecoration(
                  color: AppColors.primaryButton,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.6), width: 2),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.white,
                        child: Text(
                          firstLetter,
                          style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primaryButton),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      userName,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold, 
                        fontSize: 18, 
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.userEmail ?? '',
                      style: GoogleFonts.poppins(
                        fontSize: 13, 
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Drawer Items
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                        _drawerTile(Icons.person_outline_rounded, 'My Profile', () => Navigator.pushNamed(context, '/profile')),
                        if (!isAdmin) ...[
                          _drawerTile(Icons.favorite_border_rounded, 'Wishlist', () => Navigator.pushNamed(context, '/wishlist')),
                          // _drawerTile(Icons.compare_arrows_rounded, 'Compare Products', () => Navigator.pushNamed(context, '/compare')),
                        ],
                        if (!isAdmin)
                          Consumer<QuoteViewModel>(
                            builder: (context, quoteVM, _) {
                              final count = quoteVM.unreadQuotesCount;
                              return _drawerTile(
                                Icons.format_quote_rounded,
                                'My Quotes',
                                () => Navigator.pushNamed(context, '/quotes'),
                                trailing: count > 0
                                    ? Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.redAccent,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          '$count',
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      )
                                    : null,
                              );
                            },
                          ),
                        if (isAdmin)
                          Consumer<QuoteViewModel>(
                            builder: (context, quoteVM, _) {
                              final count = quoteVM.unreadAdminEnquiriesCount;
                              return _drawerTile(
                                Icons.admin_panel_settings_rounded,
                                'Design Enquiries',
                                () {
                                  Navigator.pop(context);
                                  Navigator.pushNamed(context, '/admin_enquiries');
                                },
                                trailing: count > 0
                                    ? Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.redAccent,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          '$count',
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      )
                                    : null,
                              );
                            },
                          ),
                        _drawerTile(Icons.delete_forever_outlined, 'Delete Account', () {
                          Navigator.pop(context);
                          _showDeleteAccountDialog(this.context, auth);
                        }),

        
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        child: Divider(color: Colors.grey[200], thickness: 1),
                      ),
                      
                      _drawerTile(Icons.help_outline_rounded, 'FAQ', () {
                        Navigator.pushNamed(context, '/faq');
                      }),
                      _drawerTile(Icons.policy_outlined, 'Terms & Conditions', () => Navigator.pushNamed(context, '/terms_conditions')),
                      
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),


              if (user != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        offset: const Offset(0, -4),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      _showLogoutDialog(this.context, auth);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Logout', 
                            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.redAccent),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _drawerTile(IconData icon, String title, VoidCallback onTap, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryButton.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primaryButton, size: 20),
        ),
        title: Text(title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87)),
        trailing: trailing ?? const Icon(Icons.chevron_right_rounded, color: Colors.black26, size: 20),
        onTap: onTap,
        dense: true,
        hoverColor: Colors.grey[50],
      ),
    );
  }
}