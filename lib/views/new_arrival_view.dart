import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/network/dio_client.dart';
import '../viewmodels/jewelry_viewmodel.dart';
import 'components/jewelry_item_card.dart';

class NewArrivalView extends StatefulWidget {
  const NewArrivalView({Key? key}) : super(key: key);

  @override
  State<NewArrivalView> createState() => _NewArrivalViewState();
}

class _NewArrivalViewState extends State<NewArrivalView> {
  final Set<String> _precachedUrls = {};

  void _precacheImages(List<dynamic> items) {
    for (var item in items) {
      if (item.imageShow != null && item.imageShow!.isNotEmpty) {
        final url = DioClient.getFullImageUrl(item.imageShow);
        if (!_precachedUrls.contains(url)) {
          _precachedUrls.add(url);
          precacheImage(
            CachedNetworkImageProvider(
              url,
              maxWidth: 400,
              maxHeight: 400,
            ),
            context,
          );
        }
      }
    }
  }
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<JewelryViewModel>(context, listen: false).fetchNewArrivals();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF8F5),
      appBar: AppBar(
        title: Text('New Arrival', style: GoogleFonts.poppins(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Consumer<JewelryViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoadingArrivals) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryButton));
          }
          if (vm.newArrivals.isEmpty) {
            return Center(child: Text("No new arrivals found.", style: GoogleFonts.poppins()));
          }

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _precacheImages(vm.newArrivals);
            }
          });

          return GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 16,
              childAspectRatio: 0.58,
            ),
            itemCount: vm.newArrivals.length,
            itemBuilder: (context, index) {
              final item = vm.newArrivals[index];
              return JewelryItemCard(item: item);
            },
          );
        },
      ),
    );
  }
}
