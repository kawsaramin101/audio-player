import 'package:flutter/material.dart';
import 'package:music/componants/home/all_songs.dart';
import 'package:music/componants/shared/player.dart';
import 'package:music/tabs/playlist.dart' as playlist;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TabBar(
        controller: _tabController,
        tabs: const <Widget>[
          Tab(
            text: "Home",
          ),
          Tab(
            text: "Playlists",
          )
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: const <Widget>[
          Center(
            child: AllSongs(),
          ),
          Center(
            child: playlist.Playlist(),
          )
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.deepPurple[800],
        height: 90.0,
        child: const Player(),
      ),
    );
  }
}
