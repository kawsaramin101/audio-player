import 'package:flutter/material.dart';
import 'package:music/data/playlist_model.dart';
import 'package:yaru/yaru.dart';

class MyAppbar extends StatelessWidget implements PreferredSizeWidget {
  final Playlist? selectedPlaylist;
  const MyAppbar({super.key, required this.selectedPlaylist});

  @override
  Widget build(BuildContext context) {
    return YaruWindowTitleBar(
      titleSpacing: 0.0,
      backgroundColor: const Color(0xFF28292A),
      leading: MenuAnchor(
          builder:
              (BuildContext context, MenuController controller, Widget? child) {
            return YaruIconButton(
              onPressed: () {
                if (controller.isOpen) {
                  controller.close();
                } else {
                  controller.open();
                }
              },
              icon: const Icon(
                YaruIcons.menu,
              ),
              tooltip: 'Show menu',
            );
          },
          menuChildren: [
            MenuItemButton(
              style: ButtonStyle(
                padding: WidgetStateProperty.all(const EdgeInsets.all(16.0)),
              ),
              onPressed: () => {},
              leadingIcon: const Icon(YaruIcons.settings),
              child: const Text('Settings'),
            ),
            MenuItemButton(
              style: ButtonStyle(
                padding: WidgetStateProperty.all(const EdgeInsets.all(16.0)),
              ),
              onPressed: () => {},
              leadingIcon: const Icon(YaruIcons.keyboard_shortcuts),
              child: const Text('Keyboard Shortcuts'),
            ),
          ]),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          YaruIconButton(
            icon: const Icon(YaruIcons.plus),
            onPressed: () {},
            tooltip: "Create note",
          ),
          SizedBox(
            width: 350,
            height: 34.0,
            child: TextField(
              // onChanged: onSearchChanged,
              decoration: InputDecoration(
                filled: true,
                hintText: selectedPlaylist == null
                    ? "Search"
                    : "Search ${selectedPlaylist!.name}",
                hintStyle: const TextStyle(
                  fontSize: 13.0,
                ),
                prefixIcon: const Icon(
                  YaruIcons.search,
                ),
                border: const OutlineInputBorder(
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.fromLTRB(0.0, 8.0, 8.0, 8.0),
              ),
              textAlignVertical: TextAlignVertical.center,
            ),
          ),
          const SizedBox(
            width: 8.0,
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
