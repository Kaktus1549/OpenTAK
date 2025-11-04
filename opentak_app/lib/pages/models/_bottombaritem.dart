import 'package:flutter/material.dart';

class BottomBarItemModel {
  final String iconPath;
  final String label;
  final String action;
  final Color backgroundColor;

  BottomBarItemModel({
    required this.iconPath,
    required this.label,
    this.action = '',
    required this.backgroundColor,
  });

  static List<BottomBarItemModel> getSampleItems(BuildContext context, {bool moreItems = false}) {

    List<BottomBarItemModel> items = [
      BottomBarItemModel(
        iconPath: 'assets/icons/testIcon.svg',
        label: 'Test1',
        backgroundColor: Colors.black,
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

  void handleAction(String actionName) {
    // TODO: Implement action handling logic here
  }
}