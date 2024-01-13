import 'package:admin_mondu_farm/pages/chat/chat.dart';
import 'package:admin_mondu_farm/pages/chat/chat_list.dart';
import 'package:admin_mondu_farm/pages/dashboard.dart';
import 'package:admin_mondu_farm/pages/login.dart';
import 'package:admin_mondu_farm/pages/ternak/ternak.dart';
import 'package:admin_mondu_farm/pages/users/admin.dart';
import 'package:admin_mondu_farm/pages/users/user.dart';
import 'package:admin_mondu_farm/utils/alerts.dart';
import 'package:admin_mondu_farm/utils/color.dart';
import 'package:admin_mondu_farm/utils/custom_extension.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_side_menu/flutter_side_menu.dart';

class MainPage extends StatefulWidget {
  const MainPage({
    super.key,
    this.idUser = "",
    this.idTernak = "",
    this.kategori = "",
    this.route = "dashboard",
  });
  final String idUser;
  final String route;
  final String idTernak;
  final String kategori;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final _controller = SideMenuController();

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
        title: Text(widget.route.title()),
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
    switch (widget.route) {
      case "dashboard":
        return DashboardPage();
      case "chat_list":
        return ChatList(
          idUser: widget.idUser
        );
      case "chat":
        return ChatPage(
          idUser: widget.idUser, idTernak: widget.idTernak, kategori: widget.kategori,
        );
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
          header: Container(
            margin: EdgeInsets.symmetric(vertical: 15),
            child: StreamBuilder(
              stream:
                  FirebaseDatabase.instance.ref().child("users").child(FirebaseAuth.instance.currentUser!.uid).onValue,
              builder: (context, snapshot) {
                if (snapshot.hasData && (snapshot.data!).snapshot.value != null) {
                  // Variable data mempermudah memanggil data pada database
                  Map<dynamic, dynamic> data = Map<dynamic, dynamic>.from(
                      (snapshot.data! as DatabaseEvent).snapshot.value as Map<dynamic, dynamic>);
                  return Column(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: Warna.ungu, borderRadius: BorderRadius.circular(50)),
                        child: Text(
                          "${data['nama'][0]}",
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        alignment: Alignment.center,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text("${data['nama']}"),
                        ),
                      ),
                    ],
                  );
                }
                if (snapshot.hasData) {
                  return Column(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: Warna.ungu, borderRadius: BorderRadius.circular(50)),
                        child: Text("-"),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        alignment: Alignment.center,
                        child: Text("-"),
                      ),
                    ],
                  );
                }
                return Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
          items: [
            SideMenuItemDataDivider(
              divider: Divider(color: Colors.black.withOpacity(0.3), height: 1),
              padding: EdgeInsetsDirectional.symmetric(vertical: 10, horizontal: 5),
            ),
            SideMenuItemDataTile(
              isSelected: ["dashboard", "chat"].contains(widget.route),
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => MainPage(
                      route: "dashboard",
                    ),
                  ),
                );
              },
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
              isSelected: widget.route == "user",
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => MainPage(
                      route: "user",
                    ),
                  ),
                );
              },
              title: 'Users',
              hoverColor: Warna.ungu,
              highlightSelectedColor: Warna.ungu,
              titleStyle: const TextStyle(color: Colors.black),
              icon: const Icon(Icons.people_alt_outlined),
              selectedIcon: const Icon(Icons.people_alt),
            ),
            SideMenuItemDataTile(
              isSelected: widget.route == "admin",
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => MainPage(
                      route: "admin",
                    ),
                  ),
                );
              },
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
              isSelected: widget.route == "sapi",
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => MainPage(
                      route: "sapi",
                    ),
                  ),
                );
              },
              title: 'Sapi',
              icon: const Icon(Icons.filter_hdr_outlined),
              hoverColor: Warna.ungu,
              highlightSelectedColor: Warna.ungu,
              titleStyle: const TextStyle(color: Colors.black),
              selectedIcon: const Icon(Icons.filter_hdr_sharp),
            ),
            SideMenuItemDataTile(
              isSelected: widget.route == "kuda",
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => MainPage(
                      route: "kuda",
                    ),
                  ),
                );
              },
              title: 'kuda',
              icon: const Icon(Icons.filter_hdr_outlined),
              hoverColor: Warna.ungu,
              highlightSelectedColor: Warna.ungu,
              titleStyle: const TextStyle(color: Colors.black),
              selectedIcon: const Icon(Icons.filter_hdr_sharp),
            ),
            SideMenuItemDataTile(
              isSelected: widget.route == "kerbau",
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => MainPage(
                      route: "kerbau",
                    ),
                  ),
                );
              },
              title: 'kerbau',
              icon: const Icon(Icons.filter_hdr_outlined),
              hoverColor: Warna.ungu,
              highlightSelectedColor: Warna.ungu,
              titleStyle: const TextStyle(color: Colors.black),
              selectedIcon: const Icon(Icons.filter_hdr_sharp),
            ),
            SideMenuItemDataTile(
              isSelected: widget.route == "kambing",
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => MainPage(
                      route: "kambing",
                    ),
                  ),
                );
              },
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
              isSelected: widget.route == "logout",
              onTap: () {
                Alerts.showAlertYesNoLogout(
                    title: "Are you sure you want to Logout?",
                    onPressYes: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.pop(context);
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx) => LoginPage()));
                    },
                    onPressNo: () {
                      Navigator.pop(context);
                    },
                    context: context);
              },
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
