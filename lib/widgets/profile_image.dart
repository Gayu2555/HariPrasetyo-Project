import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

// ==================== PROFILE IMAGE WIDGET (Redesigned) ====================
class ProfileImage extends StatelessWidget {
  final double height;
  final String image;
  final String? fallbackName; // Untuk initial fallback
  final bool showBorder; // Optional border
  final double borderWidth; // Ketebalan border

  const ProfileImage({
    Key? key,
    required this.height,
    required this.image,
    this.fallbackName,
    this.showBorder = true,
    this.borderWidth = 3.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: height, // Make it perfectly circular
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: showBorder
            ? Border.all(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
                width: borderWidth,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: image.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: image,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor,
                      ),
                      strokeWidth: 2.5,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) =>
                    _buildAvatarFallback(context),
              )
            : _buildAvatarFallback(context),
      ),
    );
  }

  // ✅ Avatar fallback dengan inisial (selaras dengan ProfileScreen)
  Widget _buildAvatarFallback(BuildContext context) {
    String initial = 'U';

    if (fallbackName != null && fallbackName!.isNotEmpty) {
      initial = fallbackName![0].toUpperCase();
    }

    return Container(
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            fontSize: height * 0.4, // Responsive font size
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ),
    );
  }
}

// ==================== PROFILE IMAGE WITH EDIT BUTTON ====================
// Widget tambahan untuk profile dengan tombol edit (opsional)
class EditableProfileImage extends StatelessWidget {
  final double height;
  final String image;
  final String? fallbackName;
  final VoidCallback? onEditTap;

  const EditableProfileImage({
    Key? key,
    required this.height,
    required this.image,
    this.fallbackName,
    this.onEditTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ProfileImage(
          height: height,
          image: image,
          fallbackName: fallbackName,
        ),
        if (onEditTap != null)
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: onEditTap,
              child: Container(
                height: height * 0.3,
                width: height * 0.3,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: height * 0.15,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class SmallProfileImage extends StatelessWidget {
  final String image;
  final String? fallbackName;
  final double size;

  const SmallProfileImage({
    Key? key,
    required this.image,
    this.fallbackName,
    this.size = 40.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProfileImage(
      height: size,
      image: image,
      fallbackName: fallbackName,
      showBorder: true,
      borderWidth: 2.0,
    );
  }
}
