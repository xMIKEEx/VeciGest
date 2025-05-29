import 'package:flutter/material.dart';

class NavigationManager {
  final Map<int, List<Widget>> _navigationStack = {
    0: [],
    1: [],
    2: [],
    3: [],
    4: [],
  };

  /// Push a new page to the current tab's navigation stack
  void pushToTab(int tabIndex, Widget page) {
    _navigationStack[tabIndex]?.add(page);
  }

  /// Pop the current page from the current tab's navigation stack
  bool popFromTab(int tabIndex) {
    final currentStack = _navigationStack[tabIndex];
    if (currentStack != null && currentStack.isNotEmpty) {
      currentStack.removeLast();
      return true;
    }
    return false;
  }

  /// Get the current stack for a tab
  List<Widget> getStackForTab(int tabIndex) {
    return _navigationStack[tabIndex] ?? [];
  }

  /// Check if a tab has sub-pages
  bool hasSubPages(int tabIndex) {
    final stack = _navigationStack[tabIndex];
    return stack != null && stack.isNotEmpty;
  }

  /// Get the top page from a tab's navigation stack
  Widget? getTopPageForTab(int tabIndex) {
    final stack = _navigationStack[tabIndex];
    if (stack != null && stack.isNotEmpty) {
      return stack.last;
    }
    return null;
  }

  /// Clear all navigation stacks
  void clearAll() {
    for (var stack in _navigationStack.values) {
      stack.clear();
    }
  }

  /// Clear navigation stack for a specific tab
  void clearTab(int tabIndex) {
    _navigationStack[tabIndex]?.clear();
  }
}
