import 'dart:async';

import 'package:flutter/material.dart';
import 'package:music/data/playlist_model.dart';
import 'package:music/notifiers/search_notifier.dart';
import 'package:provider/provider.dart';
import 'package:yaru/yaru.dart';

class MyAppbar extends StatefulWidget implements PreferredSizeWidget {
  final Playlist? selectedPlaylist;
  const MyAppbar({super.key, required this.selectedPlaylist});

  @override
  State<MyAppbar> createState() => _MyAppbarState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class _MyAppbarState extends State<MyAppbar> {
  Timer? _debounce;

  @override
  Widget build(BuildContext context) {
    final searchNotifierProvider = Provider.of<SearchNotifierProvider>(context);

    void onSearchChanged(String newValue) {
      if (newValue.isEmpty) {
        searchNotifierProvider.valueNotifier.value = newValue;
        _debounce?.cancel();
      } else {
        if (_debounce?.isActive ?? false) _debounce!.cancel();
        _debounce = Timer(const Duration(milliseconds: 500), () {
          searchNotifierProvider.valueNotifier.value = newValue;
        });
      }
    }

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
              onChanged: onSearchChanged,
              decoration: InputDecoration(
                filled: true,
                hintText: widget.selectedPlaylist == null
                    ? "Search"
                    : "Search ${widget.selectedPlaylist!.name}",
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
}
