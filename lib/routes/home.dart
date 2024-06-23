import 'package:flutter/material.dart';
import 'package:music/routes/tabs/all_songs.dart';
import 'package:music/routes/tabs/playlists.dart' as playlist;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late final TabController _tabController;

  @override
  bool get wantKeepAlive => true;

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
    super.build(context);
    return Scaffold(
      appBar: TabBar(
        controller: _tabController,
        tabs: const <Widget>[
          Tab(
            text: "All songs",
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
            child: playlist.Playlists(),
          )
        ],
      ),
    );
  }
}
