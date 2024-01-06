import 'package:admin_mondu_farm/pages/login.dart';
import 'package:admin_mondu_farm/pages/ternak/ternak.dart';
import 'package:admin_mondu_farm/pages/users/admin.dart';
import 'package:admin_mondu_farm/pages/users/user.dart';
import 'package:admin_mondu_farm/utils/color.dart';
import 'package:admin_mondu_farm/utils/custom_extension.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_side_menu/flutter_side_menu.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final _controller = SideMenuController();
  String _currentPage = "sapi";

  void cekUser() async {
    await FirebaseAuth.instance.currentUser;
    // Logic cek Data User apakah sudah pernah login
    if (FirebaseAuth.instance.currentUser == null) {
      FirebaseAuth.instance.currentUser;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginPage()));
      });
    }
  }

  // Code yang bakal di jalankan pertama kali halaman ini dibuka
  @override
  void initState() {
    // Cek User apakah user sudah pernah login sebelumnya
    cekUser();
    super.initState();
  }

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
      case "admin":
        return AdminTable();
      case "sapi":
        return TableTernak(
          kategori: 'sapi',
        );
      case "kuda":
        return TableTernak(
          kategori: 'kuda',
        );
      case "kerbau":
        return TableTernak(
          kategori: 'kerbau',
        );
      case "kambing":
        return TableTernak(
          kategori: 'kambing',
        );
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
              padding: EdgeInsetsDirectional.symmetric(vertical: 10, horizontal: 5),
            ),
            const SideMenuItemDataTitle(
              title: 'Tables',
              titleStyle: TextStyle(fontSize: 14),
              padding: EdgeInsetsDirectional.symmetric(vertical: 10, horizontal: 5),
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
            SideMenuItemDataTile(
              isSelected: _currentPage == "admin",
              onTap: () => setState(() => _currentPage = "admin"),
              title: 'Admins',
              hoverColor: Warna.ungu,
              highlightSelectedColor: Warna.ungu,
              titleStyle: const TextStyle(color: Colors.black),
              icon: const Icon(Icons.people_alt_outlined),
              selectedIcon: const Icon(Icons.people_alt),
            ),
            SideMenuItemDataDivider(
              divider: Divider(
                color: Colors.black.withOpacity(0.3),
                height: 1,
              ),
              padding: EdgeInsetsDirectional.symmetric(vertical: 10, horizontal: 5),
            ),
            const SideMenuItemDataTitle(
              title: 'Hewan Ternak',
              titleStyle: TextStyle(fontSize: 14),
              padding: EdgeInsetsDirectional.symmetric(vertical: 7, horizontal: 5),
            ),
            SideMenuItemDataTile(
              isSelected: _currentPage == "sapi",
              onTap: () => setState(() => _currentPage = "sapi"),
              title: 'Sapi',
              icon: const Icon(Icons.filter_hdr_outlined),
              hoverColor: Warna.ungu,
              highlightSelectedColor: Warna.ungu,
              titleStyle: const TextStyle(color: Colors.black),
              selectedIcon: const Icon(Icons.filter_hdr_sharp),
            ),
            SideMenuItemDataTile(
              isSelected: _currentPage == "kuda",
              onTap: () => setState(() => _currentPage = "kuda"),
              title: 'kuda',
              icon: const Icon(Icons.filter_hdr_outlined),
              hoverColor: Warna.ungu,
              highlightSelectedColor: Warna.ungu,
              titleStyle: const TextStyle(color: Colors.black),
              selectedIcon: const Icon(Icons.filter_hdr_sharp),
            ),
            SideMenuItemDataTile(
              isSelected: _currentPage == "kerbau",
              onTap: () => setState(() => _currentPage = "kerbau"),
              title: 'kerbau',
              icon: const Icon(Icons.filter_hdr_outlined),
              hoverColor: Warna.ungu,
              highlightSelectedColor: Warna.ungu,
              titleStyle: const TextStyle(color: Colors.black),
              selectedIcon: const Icon(Icons.filter_hdr_sharp),
            ),
            SideMenuItemDataTile(
              isSelected: _currentPage == "kambing",
              onTap: () => setState(() => _currentPage = "kambing"),
              title: 'kambing',
              icon: const Icon(Icons.filter_hdr_outlined),
              hoverColor: Warna.ungu,
              highlightSelectedColor: Warna.ungu,
              titleStyle: const TextStyle(color: Colors.black),
              selectedIcon: const Icon(Icons.filter_hdr_sharp),
            ),
            SideMenuItemDataDivider(
              divider: Divider(
                color: Colors.black.withOpacity(0.3),
                height: 1,
              ),
              padding: EdgeInsetsDirectional.symmetric(vertical: 10, horizontal: 5),
            ),
            const SideMenuItemDataTitle(
              title: 'System',
              titleStyle: TextStyle(fontSize: 14),
              padding: EdgeInsetsDirectional.symmetric(vertical: 7, horizontal: 5),
            ),
            SideMenuItemDataTile(
              isSelected: _currentPage == "logout",
              onTap: () {},
              title: 'Logout',
              icon: const Icon(Icons.power_settings_new),
              hoverColor: Warna.ungu,
              highlightSelectedColor: Warna.ungu,
              titleStyle: const TextStyle(color: Colors.black),
              selectedIcon: const Icon(Icons.power_settings_new),
            ),
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
