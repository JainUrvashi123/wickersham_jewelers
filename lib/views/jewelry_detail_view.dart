import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/jewelry_viewmodel.dart';
import '../viewmodels/cart_viewmodel.dart';
import '../core/network/dio_client.dart';
import '../viewmodels/wishlist_viewmodel.dart';
import 'cart_view.dart';
import 'components/pulsing_skeleton.dart';

class JewelryDetailView extends StatefulWidget {
  final String jewelryId;

  const JewelryDetailView({Key? key, required this.jewelryId}) : super(key: key);

  @override
  State<JewelryDetailView> createState() => _JewelryDetailViewState();
}

class _JewelryDetailViewState extends State<JewelryDetailView> {
  Map<String, dynamic>? product;
  bool _isLoading = true;
  String? _error;
  bool _isAddingToCart = false;
  bool _isWishlistLoading = false;
  List<dynamic> imageArray = [];
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    try {
      final vm = Provider.of<JewelryViewModel>(context, listen: false);
      final response = await vm.fetchJewelryDetail(widget.jewelryId);

      final records = response['records'] ?? response['record'] ?? response['data'];
      // Extract Image Array from response
      imageArray = response['image_array'] ?? [];

      if (records != null) {
        product = (records is List && records.isNotEmpty) ? records.first : records;
      } else {
        _error = "Item not found";
      }
    } catch (e) {
      _error = e.toString().replaceFirst("Exception: ", "");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleAddToCart() async {
    if (_isAddingToCart || product == null) return;
    
    setState(() {
      _isAddingToCart = true;
    });

    try {
      final authVm = Provider.of<AuthViewModel>(context, listen: false);
      final cartVm = Provider.of<CartViewModel>(context, listen: false);

      final success = await cartVm.addToCart(
        widget.jewelryId,
        '1',
      );

      if (success && mounted) {
        // Show success popup
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: Text('Success', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            content: Text(
              '${product!['product_sku'] ?? product!['product_name'] ?? 'Item'} added to cart successfully!',
              style: GoogleFonts.poppins(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('CONTINUE SHOPPING', style: GoogleFonts.poppins(color: Colors.grey)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryButton,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CartView()),
                  );
                },
                child: Text('GO TO CART', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      } else {
        throw Exception("Failed to add");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not add to cart. Try logging in.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    finally {
      if (mounted) {
        setState(() {
          _isAddingToCart = false;
        });
      }
    }
  }

  void _handleRemoveFromCart(String cartId) async {
    if (_isAddingToCart) return;

    setState(() {
      _isAddingToCart = true;
    });

    try {
      final cartVm = Provider.of<CartViewModel>(context, listen: false);
      final success = await cartVm.removeFromCart(cartId, 'jewelry');

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Removed from cart'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not remove from cart'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAddingToCart = false;
        });
      }
    }
  }

  void _handleToggleWishlist(WishlistViewModel wishlistVm, dynamic wishlistItem) async {
    final authVm = Provider.of<AuthViewModel>(context, listen: false);
    if (authVm.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to add to wishlist'), backgroundColor: Colors.red),
      );
      return;
    }

    if (_isWishlistLoading) return;

    setState(() {
      _isWishlistLoading = true;
    });

    try {
      if (wishlistItem != null) {
        final success = await wishlistVm.removeItem(authVm.user!.userId, 'jewelry', wishlistItem.wishlistId);
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Removed from wishlist'), backgroundColor: Colors.orange),
          );
        }
      } else {
        final success = await wishlistVm.addItem(authVm.user!.userId, 'jewelry', widget.jewelryId);
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Added to wishlist'), backgroundColor: Colors.green),
          );
        } else if (!success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(wishlistVm.errorMessage ?? 'Failed to add to wishlist'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
    } finally {
      if (mounted) {
        setState(() {
          _isWishlistLoading = false;
        });
      }
    }
  }


  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: Stack(
            fit: StackFit.expand,
            children: [
              InteractiveViewer(
                panEnabled: true,
                minScale: 0.5,
                maxScale: 4.0,
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                  errorWidget: (context, url, error) => const Center(
                    child: Icon(Icons.broken_image, color: Colors.white, size: 50),
                  ),
                ),
              ),
              Positioned(
                top: 40,
                right: 20,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSpecRow(String label, String value) {
    if (value.isEmpty || value == "null") return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(label, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600))),
          const Text(' -  ', style: TextStyle(color: Colors.grey)),
          Expanded(flex: 3, child: Text(value, style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authVm = Provider.of<AuthViewModel>(context);
    final bool isAdmin = authVm.user?.userType == '1';
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Product Details'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryButton))
          : _error != null
          ? Center(child: Text(_error!))
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'jewelry_${widget.jewelryId}',
              child: Stack(
                children: [
                  CarouselSlider(
                    options: CarouselOptions(
                      height: 480,
                      viewportFraction: 1.0,
                      onPageChanged: (index, reason) => setState(() => _currentImageIndex = index),
                    ),
                    items: imageArray.map((img) {
                      final imageUrl = DioClient.getFullImageUrl(img['src']);
                      return GestureDetector(
                        onTap: () => _showImageDialog(context, imageUrl),
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          memCacheHeight: 800,
                          maxWidthDiskCache: 800,
                          maxHeightDiskCache: 800,
                          filterQuality: FilterQuality.medium,
                          placeholder: (context, url) => const PulsingSkeleton(),
                          imageBuilder: (context, imageProvider) => Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => const Icon(Icons.image_not_supported, size: 50),
                        ),
                      );
                    }).toList(),
                  ),
                  // Dot Indicators
                  Positioned(
                    bottom: 10,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: imageArray.asMap().entries.map((entry) {
                        return Container(
                          width: 8.0,
                          height: 8.0,
                          margin:  const EdgeInsets.symmetric(horizontal: 4.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentImageIndex == entry.key ?  AppColors.primaryButton : Colors.grey.shade300,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product!['product_sku'] ?? product!['product_name'] ?? '',
                    style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product!['product_price_show'] ?? '\$${product!['product_price']}',
                    style: GoogleFonts.poppins(fontSize: 20, color:  AppColors.primaryButton, fontWeight: FontWeight.w600),
                  ),
                  const Divider(height: 32),

                  if (product!['product_description'] != null)
                    HtmlWidget(
                      product!['product_description'],
                      textStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.black87, height: 1.6),
                    ),

                  const SizedBox(height: 24),
                  Text("Specifications", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),

                  _buildSpecRow('Category', product!['category_name'] ?? ''),
                  _buildSpecRow('Metal', product!['metal'] ?? ''),
                  _buildSpecRow('Stone Name', product!['stone_name'] ?? ''),
                  _buildSpecRow('Stone Shape', product!['stone_shape'] ?? ''),
                  _buildSpecRow('Diamond Weight', product!['diamond_weight'] ?? ''),
                  _buildSpecRow('Fancy Diamond', product!['fancy_diamond_wt'] ?? ''),

                  const SizedBox(height: 40),


                  Row(
                    children: [
                      Expanded(
                        child: Consumer<CartViewModel>(
                          builder: (context, cartVm, child) {
                            dynamic cartItem;
                            try {
                              cartItem = cartVm.cartItems.firstWhere(
                                (c) => c.productId == widget.jewelryId,
                              );
                            } catch (_) {
                              cartItem = null;
                            }

                            final bool isInCart = cartItem != null;

                            return ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isInCart ? Colors.green : AppColors.primaryButton,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              ),
                              onPressed: (_isLoading || _isAddingToCart) 
                                  ? null 
                                  : (isInCart && cartItem != null 
                                      ? () => _handleRemoveFromCart(cartItem.cartId) 
                                      : _handleAddToCart),
                              child: _isAddingToCart
                                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        if (isInCart) ...[
                                          const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 20),
                                          const SizedBox(width: 8),
                                        ],
                                        Text(
                                          isInCart ? 'REMOVE FROM CART' : 'ADD TO CART',
                                          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                            );
                          },
                        ),
                      ),
                      if (!isAdmin) ...[
                        const SizedBox(width: 12),
                        Consumer<WishlistViewModel>(
                          builder: (context, wishlistVm, child) {
                            var wishlistItem;
                            if (wishlistVm.wishlistData != null) {
                              for (var w in wishlistVm.wishlistData!.jewelry) {
                                if (w.productId == widget.jewelryId) {
                                  wishlistItem = w;
                                  break;
                                }
                              }
                            }
                            final bool isInWishlist = wishlistItem != null;

                            return Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: IconButton(
                                onPressed: () => _handleToggleWishlist(wishlistVm, wishlistItem),
                                icon: _isWishlistLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryButton),
                                      )
                                    : Icon(
                                        isInWishlist ? Icons.favorite : Icons.favorite_border,
                                        color: isInWishlist ? Colors.red : AppColors.primaryButton,
                                      ),
                                padding: const EdgeInsets.all(12),
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
