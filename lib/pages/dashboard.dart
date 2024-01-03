import 'package:admin_mondu_farm/pages/user.dart';
import 'package:admin_mondu_farm/utils/color.dart';
import 'package:admin_mondu_farm/utils/custom_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_side_menu/flutter_side_menu.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final _controller = SideMenuController();
  String _currentPage = "user";

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentPage.title()),
        backgroundColor: Warna.biru,
        elevation: 1,
        shadowColor: Colors.black,
      ),
      drawer: width < 600 ? sidebar() : null,
      body: Row(
        children: [
          if (width > 600) sidebar(),
          Expanded(
            child: Container(
              color: Warna.latar,
              child: Container(
                margin: EdgeInsets.all(25),
                padding: EdgeInsets.all(25),
            
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: Warna.biru,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.4),
                      spreadRadius: 2,
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: bodyWidget(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget bodyWidget() {
    switch (_currentPage) {
      case "dashboard":
        return Container();
      case "user":
        return UserTable();
      default:
        return Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("404"),
              Text("Page not found"),
            ],
          ),
        );
    }
  }

  SideMenu sidebar() {
    return SideMenu(
      controller: _controller,
      backgroundColor: Warna.biru,
      mode: SideMenuMode.open,
      hasResizer: false,
      hasResizerToggle: false,
      builder: (data) {
        return SideMenuData(
          header: const Text('Header'),
          items: [
            SideMenuItemDataTile(
              isSelected: _currentPage == "dashboard",
              onTap: () => setState(() => _currentPage = "dashboard"),
              title: 'Dashboard',
              hoverColor: Warna.ungu,
              highlightSelectedColor: Warna.ungu,
              titleStyle: const TextStyle(color: Colors.black),
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home),
              badgeStyle: BadgeStyle(
                badgeColor: Warna.biruUngu,
              ),
              badgeContent: const Text(
                '23',
                style: TextStyle(
                  fontSize: 8,
                  color: Colors.black,
                ),
              ),
            ),
            SideMenuItemDataDivider(
              divider: Divider(color: Colors.black.withOpacity(0.3), height: 1),
            ),
            const SideMenuItemDataTitle(
              title: 'Tables',
              titleStyle: TextStyle(fontSize: 14),
            ),
            SideMenuItemDataTile(
              isSelected: _currentPage == "user",
              onTap: () => setState(() => _currentPage = "user"),
              title: 'Users',
              hoverColor: Warna.ungu,
              highlightSelectedColor: Warna.ungu,
              titleStyle: const TextStyle(color: Colors.black),
              icon: const Icon(Icons.people_alt_outlined),
              selectedIcon: const Icon(Icons.people_alt),
            ),
            // SideMenuItemDataTile(
            //   isSelected: _currentPage == "dashboard",
            //   onTap: () => setState(() => _currentPage = "dashboard"),
            //   title: 'Item 3',
            //   icon: const Icon(Icons.play_arrow),
            //   hoverColor: Warna.ungu,
            //   highlightSelectedColor: Warna.ungu,
            //   titleStyle: const TextStyle(color: Colors.black),
            //   selectedIcon: const Icon(Icons.home),
            // ),
            // SideMenuItemDataTile(
            //   isSelected: _currentPage == "dashboard",
            //   onTap: () => setState(() => _currentPage = "dashboard"),
            //   title: 'Item 4',
            //   icon: const Icon(Icons.car_crash),
            //   hoverColor: Warna.ungu,
            //   highlightSelectedColor: Warna.ungu,
            //   titleStyle: const TextStyle(color: Colors.black),
            //   selectedIcon: const Icon(Icons.home),
            // ),
          ],
          footer: GestureDetector(
            onTap: () {
              _controller.toggle();
            },
            child: Container(
              decoration: BoxDecoration(
                  border: Border(
                      top: BorderSide(
                color: Colors.black,
              ))),
              alignment: Alignment.centerRight,
              height: 50,
              margin: EdgeInsets.symmetric(horizontal: 15),
              width: double.infinity,
              child: SizedBox(
                child: Icon(
                  Icons.arrow_back_ios_new_outlined,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
