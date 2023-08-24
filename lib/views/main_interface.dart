import 'package:fitist/views/map_page/session_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fitist/views/contacts_page/contacts_page.dart';
import 'package:fitist/views/settings_page/settings_page.dart';

import 'map_page/map_page.dart';

class MainInterface extends StatefulWidget {
  final onSignOut;

  const MainInterface({Key key, @required this.onSignOut}) : super(key: key);
  // ignore: non_constant_identifier_names
  final ANIMATION_DURATION = const Duration(milliseconds: 500);

  @override
  State<StatefulWidget> createState() => new _MainInterfaceState();
}

class _MainInterfaceState extends State<MainInterface>
    with TickerProviderStateMixin {
  int _pageIndex = 1;

  // getter allows the access to widget.onSignOut
  get _pages => <Widget>[
        ContactsPage(),
        MapPage(),
        SettingsPage(onSignOut: widget.onSignOut),
      ];

  void _changePage(int page) {
    setState(() {
      _pageIndex = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMapPage = _pageIndex == 1;
    final menuItems = <BottomNavigationBarItem>[
      const BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.chat_bubble_2_fill), label: 'Chat'),
      if (!isMapPage)
        BottomNavigationBarItem(icon: Icon(CupertinoIcons.map), label: 'Map')
      else
        BottomNavigationBarItem(icon: Container(), label: 'Map'),
      const BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.settings), label: 'Settings'),
    ];

    final viewPadding = MediaQuery.of(context).viewPadding;

    return Scaffold(
      body: _pages[_pageIndex],
      floatingActionButton: AnimatedSize(
        duration: widget.ANIMATION_DURATION,
        curve: Curves.easeOutBack,
        vsync: this,
        child: SizedBox(
          width: (isMapPage) ? 50 : 0,
          child: SessionButton(isMapPage: isMapPage),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: MediaQuery(
        data: MediaQueryData(
          viewPadding: EdgeInsets.zero,
        ),
        child: IntrinsicHeight(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              BottomAppBar(
                clipBehavior: Clip.antiAlias,
                shape: CircularNotchedRectangle(),
                notchMargin: (isMapPage) ? 5 : 0,
                child: BottomNavigationBar(
                  backgroundColor: Theme.of(context).primaryColor,
                  unselectedItemColor: Color(0xffdddddd),
                  selectedItemColor: Color(0xffeeeeee),
                  showSelectedLabels: false,
                  showUnselectedLabels: false,
                  items: menuItems,
                  onTap: _changePage,
                  currentIndex: _pageIndex,
                ),
                elevation: 10,
              ),
              // Fill the view padding space below nav bar with nav bar color
              Container(
                color: Theme.of(context).primaryColor,
                height: viewPadding.bottom,
              )
            ],
          ),
        ),
      ),
    );
  }
}
