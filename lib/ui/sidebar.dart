import 'package:flutter/material.dart';

class NavItem {
  final IconData icon;
  final String label;
  const NavItem(this.icon, this.label);
}

class AppSidebar extends StatelessWidget {
  final List<NavItem> items;
  final int selected;
  final ValueChanged<int> onSelect;
  const AppSidebar({super.key, required this.items, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 230,
      child: Material(
        color: Colors.transparent,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          itemCount: items.length,
          itemBuilder: (context, i) {
            return Material(
              type: MaterialType.transparency,
              shape: const StadiumBorder(),
              child: ListTile(
                dense: true,
                leading: Icon(items[i].icon, size: 20),
                title: Text(items[i].label),
                selected: i == selected,
                selectedColor: scheme.onSecondaryContainer,
                selectedTileColor: scheme.secondaryContainer,
                shape: const StadiumBorder(),
                onTap: () => onSelect(i),
              ),
            );
          },
        ),
      ),
    );
  }
}
