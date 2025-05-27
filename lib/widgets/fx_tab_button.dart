import 'package:flutter/material.dart';

import '../app/constants.dart';

class FxTabButton extends StatelessWidget {
  final int selectedIndex;
  final void Function(int tab) onSelectedTab;
  final List<String> tabs;
  const FxTabButton({
    required this.tabs,
    this.selectedIndex = 0,
    required this.onSelectedTab,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Container(
        color: Colors.grey.shade300,
        height: 40,
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () {
                  onSelectedTab(0);
                },
                child: _TabButtonItem(
                    isActive: selectedIndex == 0, title: tabs[0]),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  onSelectedTab(1);
                },
                child: _TabButtonItem(
                    isActive: selectedIndex == 1, title: tabs[1]),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _TabButtonItem extends StatelessWidget {
  final bool isActive;
  final String title;
  const _TabButtonItem({
    super.key,
    required this.isActive,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 1.0),
          child: Container(
            decoration: BoxDecoration(
              color: !isActive ? Colors.grey.shade300 : Colors.white,
              border: isActive
                  ? const Border(
                      top: BorderSide(color: Constants.greenDark),
                      left: BorderSide(color: Constants.greenDark),
                      right: BorderSide(color: Constants.greenDark),
                      bottom: BorderSide.none,
                    )
                  : const Border(
                      bottom: BorderSide(color: Constants.greenDark),
                    ),
              borderRadius: !isActive
                  ? null
                  : const BorderRadius.only(
                      topRight: Radius.circular(10),
                      topLeft: Radius.circular(10),
                    ),
            ),
            child: Center(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: !isActive
                      ? Colors.grey.withOpacity(0.7)
                      : Constants.greenDark,
                  fontWeight: isActive ? FontWeight.normal : FontWeight.normal,
                ),
              ),
            ),
          ),
        ),
        if (isActive)
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              child: Container(
                color: Colors.white,
                height: 2,
              ),
            ),
          ),
      ],
    );
  }
}
