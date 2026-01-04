import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:opentak_app/points/_point.dart';


double sizeForZoom(double zoom) {
  const double hideBelowZoom = 12.0; 
  const double fullSizeZoom  = 17.0; 

  const double minSize = 14.0;
  const double maxSize = 34.0;

  if (zoom < hideBelowZoom) return 0.0;

  final t = ((zoom - hideBelowZoom) / (fullSizeZoom - hideBelowZoom)).clamp(0.0, 1.0);
  final eased = t * t * (3 - 2 * t); 
  return minSize + (maxSize - minSize) * eased;
}

class DeletablePointMarker extends StatelessWidget {
  const DeletablePointMarker({
    super.key,
    required this.point,
    required this.onDelete,
    required this.iconSize,
    required this.showDeleteButton,
  });

  final Point point;
  final VoidCallback onDelete;
  final double iconSize;
  final bool showDeleteButton;

  @override
  Widget build(BuildContext context) {
    final pad = (iconSize * 0.18).clamp(4.0, 10.0);
    final box = iconSize + pad * 2;

    const double tapTarget = 52.0;
    final visibleBtn = (iconSize * 0.55).clamp(20.0, 28.0);
    final closeIconSize = (visibleBtn * 0.6).clamp(12.0, 16.0);

    return SizedBox(
      width: box,
      height: box,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Align(
            alignment: Alignment.center,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onLongPress: onDelete, 
              child: SvgPicture.asset(
                'assets/points/${point.name}.svg',
                width: iconSize,
                height: iconSize,
              ),
            ),
          ),

          if (showDeleteButton)
            Positioned(
              top: pad - (tapTarget - visibleBtn) / 2,
              right: pad - (tapTarget - visibleBtn) / 2,
              child: SizedBox(
                width: tapTarget,
                height: tapTarget,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: onDelete,
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        width: visibleBtn,
                        height: visibleBtn,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 191),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 204),
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Icon(Icons.close, size: closeIconSize, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}