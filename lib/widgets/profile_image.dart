// lib/widgets/profile_image.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ProfileImage extends StatelessWidget {
  final double height;
  final String image;
  final bool showBorder;
  final bool showOnlineIndicator;
  final VoidCallback? onTap;

  const ProfileImage({
    Key? key,
    required this.height,
    required this.image,
    this.showBorder = false,
    this.showOnlineIndicator = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          // Main Profile Image Container
          Container(
            height: height,
            width: height,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: showBorder
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withOpacity(0.6),
                      ],
                    )
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 12,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(showBorder ? 3.0 : 0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: image,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey.shade200,
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey.shade300,
                      child: Icon(
                        Icons.person,
                        size: height * 0.5,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Online Indicator
          if (showOnlineIndicator)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                height: height * 0.25,
                width: height * 0.25,
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Enhanced version with shimmer effect
class ProfileImageWithShimmer extends StatelessWidget {
  final double height;
  final String image;
  final bool showBorder;
  final bool showOnlineIndicator;
  final VoidCallback? onTap;

  const ProfileImageWithShimmer({
    Key? key,
    required this.height,
    required this.image,
    this.showBorder = false,
    this.showOnlineIndicator = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            height: height,
            width: height,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: showBorder
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withOpacity(0.6),
                      ],
                    )
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: showBorder ? 2 : 0,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(showBorder ? 3.5 : 0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: image,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => _buildShimmerPlaceholder(),
                    errorWidget: (context, url, error) => _buildErrorWidget(),
                  ),
                ),
              ),
            ),
          ),
          if (showOnlineIndicator) _buildOnlineIndicator(),
        ],
      ),
    );
  }

  Widget _buildShimmerPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey.shade200,
            Colors.grey.shade300,
            Colors.grey.shade200,
          ],
        ),
      ),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 1500),
        builder: (context, value, child) {
          return Opacity(
            opacity: 0.5 + (value * 0.5),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(-1.0 + (value * 2), -1.0),
                  end: Alignment(1.0 + (value * 2), 1.0),
                  colors: [
                    Colors.grey.shade200,
                    Colors.grey.shade100,
                    Colors.grey.shade200,
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.grey.shade300, Colors.grey.shade400],
        ),
      ),
      child: Icon(Icons.person, size: height * 0.5, color: Colors.white),
    );
  }

  Widget _buildOnlineIndicator() {
    return Positioned(
      bottom: height * 0.02,
      right: height * 0.02,
      child: Container(
        height: height * 0.28,
        width: height * 0.28,
        decoration: BoxDecoration(
          color: const Color(0xFF4CAF50),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: height * 0.05),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4CAF50).withOpacity(0.4),
              blurRadius: 8,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }
}
