import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:opentak_app/models/_bottombaritem.dart';
import 'package:opentak_app/Utils/_utils.dart';
import 'package:provider/provider.dart';
import 'package:opentak_app/drawing/_paint_notifiers.dart';


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

  bool closeButtonVisible = false;
  late MapStrokeController strokeController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    tabletOrLandscaped = Utils.isTabletDetectionOrLandscape(context);
    _loadItems();
  }

  void _openDrawingMenu() {
    strokeController = context.read<MapStrokeController>();
    strokeController.setDrawingEnabled(true);
    Color currentColor = strokeController.currentColor;
    double currentWidth = strokeController.currentWidth;
    Tool currentTool = strokeController.isEraser ? Tool.eraser : Tool.pen;
    setState(() {
      closeButtonVisible = true;
      items = BottomBarItemModel.getDrawingMenuItems(
        context,
        widget.slidingPanelUp,
        context.read<DrawingController>(),
        currentColor,
        currentTool,
        _updateCurrentTool,
        _updateDrawingSettings,
        currentWidth: currentWidth,
      );
    });
  }

  void _refreshDrawingItems() {
    Color currentColor = strokeController.currentColor;
    double currentWidth = strokeController.currentWidth;
    Tool currentTool = strokeController.isEraser ? Tool.eraser : Tool.pen;
    items = BottomBarItemModel.getDrawingMenuItems(
      context,
      widget.slidingPanelUp,
      context.read<DrawingController>(),
      currentColor,
      currentTool,
      _updateCurrentTool,
      _updateDrawingSettings,
      currentWidth: currentWidth,
    );
  }


  void close(){
    MapStrokeController strokeController = context.read<MapStrokeController>();
    setState(() {
      closeButtonVisible = false;
      strokeController.setDrawingEnabled(false);
      items = BottomBarItemModel.getItems(context, _openDrawingMenu, moreItems: tabletOrLandscaped);
      items.add(
        BottomBarItemModel(
          iconPath: 'assets/icons/moreIcons.svg',
          label: 'All Icons',
          action: 'slideUp',
          backgroundColor: Colors.black,
        ),
      );
    });
  }

  void _updateDrawingSettings(Color color, double width) {
    setState(() {
      strokeController.setColor(color);
      strokeController.setStrokeWidth(width);
      _refreshDrawingItems();
    });
  }

  void _updateCurrentTool() {
    setState(() {
      MapStrokeController strokeController = context.read<MapStrokeController>();
      if (strokeController.isEraser == false) {
        strokeController.setEraser();
      } else {
        strokeController.setPen();
      }
      _refreshDrawingItems();
    });
  }

  void _allIconsTapped() {
    if (!widget.slidingPanelUp) {
      widget.onTap();
    }
  }

  void _loadItems() {
    items = BottomBarItemModel.getItems(context, _openDrawingMenu, moreItems: tabletOrLandscaped);
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
      if (i == items.length - 1 && !closeButtonVisible) {
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
            onTap: item.onTap ?? _allIconsTapped,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (item.iconPath != '') SvgPicture.asset(item.iconPath, width: 36, height: 36),
                if (item.iconData != null && item.iconPath == '') Icon(item.iconData, size: 36, color: Colors.white),
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
    if (closeButtonVisible) {
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
      // Add close button
      children.add(
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: close,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.close, size: 36, color: Colors.white),
                Text(
                  'Close',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14, color: Colors.white),
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