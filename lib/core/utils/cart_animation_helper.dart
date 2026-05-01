import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../constants/api_constants.dart';
import '../theme/app_colors.dart';

class CartAnimationHelper {
  static void runFlyToCartAnimation({
    required BuildContext context,
    required GlobalKey sourceKey,
    required GlobalKey destKey,
    required String? imageUrl,
    VoidCallback? onComplete,
  }) {
    final OverlayState overlayState = Overlay.of(context);

    // Get positions
    final RenderBox? sourceBox =
        sourceKey.currentContext?.findRenderObject() as RenderBox?;
    final RenderBox? destBox =
        destKey.currentContext?.findRenderObject() as RenderBox?;

    if (sourceBox == null || destBox == null) return;

    final Offset sourceOffset = sourceBox.localToGlobal(Offset.zero);
    final Offset destOffset = destBox.localToGlobal(Offset.zero);

    // Center of widgets
    final Offset start = Offset(
      sourceOffset.dx + sourceBox.size.width / 2,
      sourceOffset.dy + sourceBox.size.height / 2,
    );
    final Offset end = Offset(
      destOffset.dx + destBox.size.width / 2,
      destOffset.dy + destBox.size.height / 2,
    );

    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) {
        return _FlyItem(
          start: start,
          end: end,
          imageUrl: imageUrl,
          onComplete: () {
            entry.remove();
            onComplete?.call();
          },
        );
      },
    );

    overlayState.insert(entry);
  }
}

class _FlyItem extends StatefulWidget {
  final Offset start;
  final Offset end;
  final String? imageUrl;
  final VoidCallback onComplete;

  const _FlyItem({
    required this.start,
    required this.end,
    this.imageUrl,
    required this.onComplete,
  });

  @override
  State<_FlyItem> createState() => _FlyItemState();
}

class _FlyItemState extends State<_FlyItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.fastOutSlowIn,
    );

    _controller.forward().then((_) => widget.onComplete());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final t = _animation.value;

        // Quadratic Bezier curve
        final Offset control = Offset(
          widget.start.dx + (widget.end.dx - widget.start.dx) * 0.2,
          widget.start.dy - 120,
        );

        final double dx =
            (1 - t) * (1 - t) * widget.start.dx +
            2 * (1 - t) * t * control.dx +
            t * t * widget.end.dx;
        final double dy =
            (1 - t) * (1 - t) * widget.start.dy +
            2 * (1 - t) * t * control.dy +
            t * t * widget.end.dy;

        final double size = 48 * (1 - t * 0.4);

        return Positioned(
          left: dx - size / 2,
          top: dy - size / 2,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 12,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(size / 2),
              child: widget.imageUrl != null && widget.imageUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: ApiConstants.getImageUrl(widget.imageUrl!)!,
                      fit: BoxFit.cover,
                    )
                  : const Icon(
                      Icons.lunch_dining,
                      size: 20,
                      color: AppColors.primary,
                    ),
            ),
          ),
        );
      },
    );
  }
}
