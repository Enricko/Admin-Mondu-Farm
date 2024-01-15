import 'package:admin_mondu_farm/pages/main_page.dart';
import 'package:admin_mondu_farm/utils/color.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "Dashboard",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        SizedBox(
          height: 15,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Container(
            //   width: 50,
            //   height: 50,
            //   alignment: Alignment.center,
            //   decoration: BoxDecoration(
            //     color: Warna.ungu,
            //     borderRadius: BorderRadius.circular(10),
            //   ),
            //   child: Icon(Icons.message),
            // ),
            // SizedBox(
            //   width: 10,
            // ),
            Tooltip(
              message: "Booking",
              child: Container(
                width: 50,
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Warna.ungu,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.library_books),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 25,
        ),
        
        Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 15),
            child: StreamBuilder(
              stream: FirebaseDatabase.instance.ref().child("pesan").onValue,
              builder: (context, snapshot) {
                if (snapshot.hasData && (snapshot.data!).snapshot.value != null) {
                  // Variable data mempermudah memanggil data pada database
                  Map<dynamic, dynamic> data = Map<dynamic, dynamic>.from(
                      (snapshot.data! as DatabaseEvent).snapshot.value as Map<dynamic, dynamic>);

                  return ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      Future<Map<dynamic, dynamic>>? dataUser = FirebaseDatabase.instance
                          .ref()
                          .child("users")
                          .child("${data.keys.toList()[index]}")
                          .get()
                          .then((value) {
                        return value.value as Map<dynamic, dynamic>;
                      });
                      return FutureBuilder(
                        future: dataUser,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Container(
                              width: double.infinity,
                              margin: EdgeInsets.symmetric(vertical: 1),
                              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                              decoration: BoxDecoration(
                                color: Warna.biruUngu,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 50,
                                        height: 50,
                                        alignment: Alignment.center,
                                        decoration:
                                            BoxDecoration(color: Warna.ungu, borderRadius: BorderRadius.circular(50)),
                                        child: Text(
                                          "${snapshot.data!['nama'][0]}",
                                          style:
                                              TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 25,
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "${snapshot.data!['nama']}",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 18,
                                            ),
                                          ),
                                          Text("${snapshot.data!['no_telepon']}"),
                                        ],
                                      )
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          Navigator.of(context).pushReplacement(
                                            MaterialPageRoute(
                                              builder: (context) => MainPage(
                                                idUser: "${data.keys.toList()[index]}",
                                                route: "chat_list",
                                              ),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          width: 50,
                                          height: 50,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: Warna.ungu,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Icon(Icons.message),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }
                          return Container(
                            width: double.infinity,
                            margin: EdgeInsets.symmetric(vertical: 1),
                            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                            decoration: BoxDecoration(
                              color: Warna.biruUngu,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 50,
                                      height: 50,
                                      alignment: Alignment.center,
                                      decoration:
                                          BoxDecoration(color: Warna.ungu, borderRadius: BorderRadius.circular(50)),
                                      child: Text("-"),
                                    ),
                                    SizedBox(
                                      width: 25,
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "----",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 18,
                                          ),
                                        ),
                                        Text("---------"),
                                      ],
                                    )
                                  ],
                                ),
                                Row(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        // Navigator.of(context).pushReplacement(
                                        //   MaterialPageRoute(
                                        //     builder: (context) => MainPage(
                                        //       uid: index.toString(),
                                        //       route: "chat",
                                        //     ),
                                        //   ),
                                        // );
                                        null;
                                      },
                                      child: Container(
                                        width: 50,
                                        height: 50,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: Warna.ungu,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Icon(Icons.message),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                }
                if (snapshot.hasData) {
                  return Center(
                    child: Text("Belum ada pesan masuk"),
                  );
                }
                return Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
