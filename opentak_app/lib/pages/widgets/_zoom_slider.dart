import 'package:settings_ui/settings_ui.dart';
import 'package:flutter/material.dart';

class ZoomSlider extends StatefulWidget {
  final int minZoom;
  final int maxZoom;
  final ValueChanged<RangeValues> onChanged;
  const ZoomSlider({
    super.key,
    required this.minZoom,
    required this.maxZoom,
    required this.onChanged,
  });
  @override
  State<ZoomSlider> createState() => _ZoomSliderState();
}

class _ZoomSliderState extends State<ZoomSlider> {
  late RangeValues _currentRange;
  
  @override
  void initState() {
    super.initState();
    _currentRange = RangeValues(
      widget.minZoom.toDouble(),
      widget.maxZoom.toDouble(),
    );
  }

  @override
  AbstractSettingsTile build(BuildContext context) {
    return SettingsTile(
      title: const Text('Zoom range'),
      description: Text('${widget.minZoom} - ${widget.maxZoom}'),
      onPressed: (context) async {
        final result = await showDialog<RangeValues>(
          context: context,
          builder: (context) {
            RangeValues tempRange = RangeValues(
              widget.minZoom.toDouble(),
              widget.maxZoom.toDouble(),
            );

            return AlertDialog(
              title: const Center(child: Text('Set zoom range')),
              content: StatefulBuilder(
                builder: (context, setState) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: Text('From ${tempRange.start.round()} to ${tempRange.end.round()}'),
                      ),
                      const SizedBox(height: 16),
                      RangeSlider(
                        values: tempRange,
                        min: 1,
                        max: 19,
                        divisions: 18,
                        labels: RangeLabels(
                          tempRange.start.round().toString(),
                          tempRange.end.round().toString(),
                        ),
                        onChanged: (value) {
                          setState(() {
                            tempRange = RangeValues(
                              value.start.roundToDouble(),
                              value.end.roundToDouble(),
                            );
                          });
                        },
                      ),
                    ],
                  );
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, tempRange),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );

        if (result != null) {
          setState(() {
            _currentRange = result;
            widget.onChanged(_currentRange);
          });
        }
      },
    );
  }
}