import 'package:flutter/material.dart';

class Utils {
  static bool isTabletDetectionOrLandscape(BuildContext context) {
    var shortestSide = MediaQuery.of(context).size.shortestSide;
    bool isTablet = shortestSide >= 600;
    bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    return isTablet || isLandscape;
  }
}