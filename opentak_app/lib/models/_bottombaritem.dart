import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:opentak_app/drawing/_paint_notifiers.dart';

enum Tool {
  pen,
  eraser,
}

class _LinePreviewPainter extends CustomPainter {
  _LinePreviewPainter(this.color, this.width);
  final Color color;
  final double width;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;

    final y = size.height / 2;
    canvas.drawLine(Offset(16, y), Offset(size.width - 16, y), p);
  }

  @override
  bool shouldRepaint(covariant _LinePreviewPainter old) =>
      old.color != color || old.width != width;
}


class BottomBarItemModel {
  final String iconPath;
  final IconData? iconData;
  final String label;
  final String action;
  final Color backgroundColor;
  final void Function()? onTap;

  BottomBarItemModel({
    required this.label,
    this.action = '',
    required this.backgroundColor,
    this.onTap,
    this.iconPath = '',
    this.iconData,
  });

  static List<BottomBarItemModel> getItems(BuildContext context, void Function() drawingCallback, {bool moreItems = false}) {

    List<BottomBarItemModel> items = [
      BottomBarItemModel(
        iconData: Icons.draw,
        label: 'Draw',
        backgroundColor: Colors.black,
        onTap: () => {
          drawingCallback(),
        },
      ),
      BottomBarItemModel(
        iconPath: 'assets/icons/testIcon.svg',
        label: 'Test2',
        backgroundColor: Colors.black,
      ),
      BottomBarItemModel(
        iconPath: 'assets/icons/testIcon.svg',
        label: 'Test3',
        backgroundColor: Colors.black,
      ),
      BottomBarItemModel(
        iconPath: 'assets/icons/testIcon.svg',
        label: 'Test4',
        backgroundColor: Colors.black,
      )
    ];

    if (moreItems) {
      items.addAll([
        BottomBarItemModel(
          iconPath: 'assets/icons/testIcon.svg',
          label: 'Test5',
          backgroundColor: Colors.black,
        ),
        BottomBarItemModel(
          iconPath: 'assets/icons/testIcon.svg',
          label: 'Test6',
          backgroundColor: Colors.black,
        ),
      ]);
    }

    return items;
  }

  static List<BottomBarItemModel> getDrawingMenuItems(BuildContext context, bool showDrawingMenu, DrawingController drawingController, Color currentColor, Tool currentTool, void Function() eraserTap, void Function(Color color, double width) colorSet, {double currentWidth = 4.0}) {
    List<BottomBarItemModel> items = [
      BottomBarItemModel(
        iconData: Icons.color_lens,
        label: "Color",
        backgroundColor: Colors.black,
        onTap: () async {
          Color tempColor = currentColor;
          double tempWidth = currentWidth;

          final cancelStyle = OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFFEDEDED),
            side: const BorderSide(color: Color(0xFF3A3A3A), width: 1),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          );

          final useStyle = FilledButton.styleFrom(
            backgroundColor: const Color(0xFF3B82F6),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          );

          final result = await showModalBottomSheet<(Color, double)>(
            context: context,
            isScrollControlled: true,
            showDragHandle: true,
            backgroundColor: Colors.black,
            barrierColor: Colors.black54,
          builder: (sheetContext) => SafeArea(
              child: Theme(
          data: ThemeData.dark().copyWith(
            canvasColor: Colors.black,
            dialogTheme: DialogThemeData(backgroundColor: Colors.black),
            scaffoldBackgroundColor: Colors.black,
            colorScheme: ColorScheme.dark(primary: tempColor),
            sliderTheme: SliderThemeData(
              activeTrackColor: Colors.white,
              inactiveTrackColor: Colors.white24,
              thumbColor: Colors.white,
              overlayColor: Colors.white24,
            ),
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) => Container(
              color: Colors.black,
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ColorPicker(
                pickerColor: tempColor,
                onColorChanged: (c) => setModalState(() => tempColor = c),
                enableAlpha: false,
                displayThumbColor: true,
              ),
              const SizedBox(height: 16),
              Container(
                height: 40,
                alignment: Alignment.center,
                child: CustomPaint(
                  size: const Size(double.infinity, 40),
                  painter: _LinePreviewPainter(tempColor, tempWidth),
                ),
              ),
              Slider(
                min: 1,
                max: 20,
                divisions: 19,
                value: tempWidth,
                label: tempWidth.toStringAsFixed(0),
                activeColor: Colors.white,
                inactiveColor: Colors.white24,
                onChanged: (v) => setModalState(() => tempWidth = v),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
              child: OutlinedButton(
                style: cancelStyle,
                onPressed: () => Navigator.pop(sheetContext),
                child: Text("Cancel", style: TextStyle(color: Colors.white)),
              ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
              child: FilledButton(
                style: useStyle,
                onPressed: () => Navigator.pop(sheetContext, (tempColor, tempWidth)),
                child: Text("Use", style: TextStyle(color: Colors.white)),
              ),
                  ),
                ],
              ),
            ],
                ),
              ),
            ),
          ),
              ),
            ),
          );

          if (result != null) {
            final (pickedColor, pickedWidth) = result;

            colorSet(currentColor = pickedColor, currentWidth = pickedWidth);

          }
        }
),
      BottomBarItemModel(
        label: currentTool == Tool.pen ? "Eraser" : "Pen",
        backgroundColor: Colors.black,
        iconData: currentTool == Tool.pen ? Icons.cleaning_services : Icons.edit,
        onTap: () {
          eraserTap();
        },
      ),
      BottomBarItemModel(
        iconData: Icons.undo,
        label: 'Undo',
        backgroundColor: Colors.black,
        onTap: () {
          drawingController.undo();
        },
      ),
      BottomBarItemModel(
        iconData: Icons.redo,
        label: 'Redo',
        backgroundColor: Colors.black,
        onTap: () {
          drawingController.redo();
        },
      ),

    ];
    return items;
  }
}