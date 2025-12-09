import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:opentak_app/widgets/_bottombar.dart' as custom_bottombar;
import 'package:opentak_app/widgets/_search.dart' as search_widget;
import 'package:opentak_app/models/_sliding_bar_item.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SlidingPanelWidget extends StatefulWidget {
  final bool navbarVisible;
  final PanelController panelController;
  final bool slidingPanelUp;
  final void Function() onTap;
  final void Function() onClose;
  final bool draggable;

  const SlidingPanelWidget({
    super.key,
    required this.navbarVisible,
    required this.panelController,
    required this.slidingPanelUp,
    required this.onTap,
    required this.onClose,
    this.draggable = false,
  });

  @override
  State<SlidingPanelWidget> createState() => _SlidingPanelWidgetState();
}

class _SlidingPanelWidgetState extends State<SlidingPanelWidget> {
  double _panelOpacity = 0.0;
  List<SlidingBarCategory> categories = SlidingBarCategory.getSampleCategories();

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      offset: widget.navbarVisible ? Offset.zero : const Offset(0, 1),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: widget.navbarVisible ? 1 : 0,
        child: Stack(
          children: [
            SlidingUpPanel(
              controller: widget.panelController,
              isDraggable: widget.draggable,
              minHeight: 100,
              maxHeight: 350,
              onPanelClosed: widget.onClose,
              onPanelSlide: (position) {
                setState(() {
                  _panelOpacity = position;
                });
              },
              color: const Color.fromRGBO(0, 0, 0, 0.93),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                ),
                panel: Opacity(
                  opacity: _panelOpacity,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 75, left: 8),
                    child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      for (var category in categories)
                        Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                          Text(
                            category.categoryName,
                            style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            alignment: WrapAlignment.start,
                            crossAxisAlignment: WrapCrossAlignment.start,
                            spacing: 16,
                            runSpacing: 16,
                            children: [
                            for (var item in category.items)
                              Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment:
                                CrossAxisAlignment.start,
                              children: [
                                SvgPicture.asset(
                                item.iconPath,
                                width: 40,
                                height: 40,
                                colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                item.label,
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                                ),
                              ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ],
                        ),
                        ),
                      ],
                    ),
                    ),
                  ),
                ),
              collapsed: custom_bottombar.BottomNavigationBar(
                slidingPanelUp: widget.slidingPanelUp,
                onTap: widget.onTap,
              ),
            ),

            Positioned(
              top: 8,
              left: 0,
              right: 0,
              child: IgnorePointer(
                ignoring: _panelOpacity < 0.1,
                child: Opacity(
                  opacity: _panelOpacity,
                  child: Column(
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[500],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: search_widget.SearchBar(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
