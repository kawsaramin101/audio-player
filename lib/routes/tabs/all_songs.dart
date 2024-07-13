import 'package:flutter/material.dart';

import 'package:music/componants/shared/songlist.dart';

class AllSongs extends StatefulWidget {
  const AllSongs({super.key});

  @override
  State<AllSongs> createState() => _AllSongsState();
}

class _AllSongsState extends State<AllSongs> {
  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Expanded(
          child: SongList(),
        ),
      ],
    );
  }
}
