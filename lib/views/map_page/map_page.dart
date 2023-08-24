import 'package:fitist/providers/map_data.dart';
import 'package:fitist/providers/map_state.dart';
import 'package:fitist/views/map_page/map_ui.dart';
import 'package:flutter/material.dart';

import 'package:fitist/views/map_page/map.dart';
import 'package:provider/provider.dart';

class MapPage extends StatelessWidget {
  const MapPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('build map page');
    return Scaffold(
      body: FutureBuilder(
        future: context.read<MapDataProvider>().init(),
        builder: (context, snapshot) {
          print('Map Page connection state: ${snapshot.connectionState}');
          if (snapshot.connectionState != ConnectionState.done) {
            return Center(child: CircularProgressIndicator());
          }
          return ChangeNotifierProvider(
            create: (_) => MapStateProvider(),
            child: Stack(
              children: [
                MapWidget(),
                MapUI(),
              ],
            ),
          );
        },
      ),
    );
  }
}
