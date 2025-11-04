import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:opentak_app/pages/models/_bottombaritem.dart';
import 'package:opentak_app/pages/Utils/_utils.dart';

class BottomNavigationBar extends StatefulWidget {
  final bool slidingPanelUp;
  final void Function() onTap;
  const BottomNavigationBar({super.key, required this.slidingPanelUp, required this.onTap});

  @override
  State<BottomNavigationBar> createState() => _BottomNavigationBarState();
}

class _BottomNavigationBarState extends State<BottomNavigationBar> {
  List<BottomBarItemModel> items = [];
  bool tabletOrLandscaped = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    tabletOrLandscaped = Utils.isTabletDetectionOrLandscape(context);
    _loadItems();
  }

  void _allIconsTapped() {
    if (!widget.slidingPanelUp) {
      widget.onTap();
    }
  }

  void _loadItems() {
    items = BottomBarItemModel.getSampleItems(context, moreItems: tabletOrLandscaped);
    items.add(
      BottomBarItemModel(
        iconPath: 'assets/icons/moreIcons.svg',
        label: 'All Icons',
        action: 'slideUp',
        backgroundColor: Colors.black,
      ),
    );
  }

  List<Widget> _buildBarChildren() {
    final children = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      if (i == items.length - 1) {
        children.add(
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: const VerticalDivider(
                width: 20,
                thickness: 1,
                color: Color(0xFFD3D3D3),
              ),
            ),
          ),
        );
      }

      final item = items[i];
      children.add(
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: item.action == 'slideUp' ? _allIconsTapped : null, // TODO: handle other actions
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(item.iconPath, width: 36, height: 36),
                Text(
                  item.label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return children;
  }

  @override
  Widget build(BuildContext context) {
    final double maxBarWidth = tabletOrLandscaped ? 600 : double.infinity;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        constraints: BoxConstraints(maxWidth: maxBarWidth),
        decoration: const BoxDecoration(
          color: Color.fromRGBO(0, 0, 0, 0.93),
          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        ),
        child: SafeArea(
          top: false,
          minimum: const EdgeInsets.only(top: 12),
          child: SizedBox(
            height: kBottomNavigationBarHeight + 25,
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _buildBarChildren(),
            ),
          ),
        ),
      ),
    );
  }
}
