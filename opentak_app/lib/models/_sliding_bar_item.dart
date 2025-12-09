class SlidingBarItem {
  final String iconPath;
  final String label;
  final String action;

  SlidingBarItem({
    required this.iconPath,
    required this.label,
    this.action = '',
  });

  static List<SlidingBarItem> generateDummies(int count) {
    return List<SlidingBarItem>.generate(
      count,
      (index) => SlidingBarItem(
        iconPath: 'assets/icons/testIcon.svg',
        label: 'Test ${index + 1}',
      ),
    );
  }
}

class SlidingBarCategory {
  final String categoryName;
  final List<SlidingBarItem> items;

  SlidingBarCategory({
    required this.categoryName,
    required this.items,
  });


  static List<SlidingBarCategory> getSampleCategories() {
    return [
      SlidingBarCategory(
        categoryName: 'Category 1',
        items: SlidingBarItem.generateDummies(4),
      ),
      SlidingBarCategory(
        categoryName: 'Category 2',
        items: SlidingBarItem.generateDummies(3),
      ),
      SlidingBarCategory(
        categoryName: 'Category 3',
        items: SlidingBarItem.generateDummies(9),
      ),
    ];
  }

}