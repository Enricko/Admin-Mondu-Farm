import 'package:admin_mondu_farm/pages/chat/chat.dart';
import 'package:admin_mondu_farm/pages/main_page.dart';
import 'package:admin_mondu_farm/utils/color.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatList extends StatefulWidget {
  const ChatList({Key? key, required this.idUser}) : super(key: key);
  final String idUser;

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  Future<String> getImageFromStorage(String pathName, String kategori) {
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage.ref().child("ternak").child(kategori.toLowerCase()).child(pathName);

    return ref.getDownloadURL();
  }

  NumberFormat currencyFormatter = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(widget.idUser);
    return Column(
      children: [
        Container(
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Warna.ungu,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: IconButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: ((context) => MainPage(
                              route: "dashboard",
                            )),
                      ),
                    );
                  },
                  icon: const Icon(Icons.arrow_back_ios_new),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder(
            stream: FirebaseDatabase.instance.ref().child("pesan").child(widget.idUser).onValue,
            builder: (context, snapshot) {
              if (snapshot.hasData && (snapshot.data!).snapshot.value != null) {
                // Variable data mempermudah memanggil data pada database
                Map<dynamic, dynamic> data = Map<dynamic, dynamic>.from(
                    (snapshot.data! as DatabaseEvent).snapshot.value as Map<dynamic, dynamic>);

                List<Map<dynamic, dynamic>> dataList = [];
                data.forEach((key, value) {
                  // Setiap data yang di perulangkan bakal di simpan ke dalam list
                  final currentData = Map<String, dynamic>.from(value);
                  // Mensetting variable dengan total lembur dan gaji)
                  dataList.add({
                    'uid': key,
                    'data': currentData['data'],
                    'kategori': currentData['kategori'],
                    'last_chat_user': currentData['last_chat_user'],
                  });
                });
                dataList.sort((a, b) {
                  var aDate = DateTime.parse(a["last_chat_user"]);
                  var bDate = DateTime.parse(b["last_chat_user"]);
                  return aDate.compareTo(bDate);
                });
                return ListView.builder(
                  itemCount: dataList.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: dataList.map(
                        (e) {
                          Future<Map<dynamic, dynamic>>? dataTernak = FirebaseDatabase.instance
                              .ref()
                              .child("ternak")
                              .child("${dataList[index]["kategori"]}")
                              .child("${dataList[index]["uid"]}")
                              .get()
                              .then((value) {
                            return value.value as Map<dynamic, dynamic>;
                          });
                          return FutureBuilder(
                              future: dataTernak,
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  var data = snapshot.data!;
                                  return ListTile(
                                    onTap: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => MainPage(
                                            idUser: widget.idUser,
                                            idTernak: dataList[index]['uid'],
                                            kategori: dataList[index]['kategori'],
                                            route: "chat",
                                          ),
                                        ),
                                      );
                                    },
                                    trailing: Icon(Icons.arrow_forward_ios),
                                    tileColor: Colors.black12,
                                    title: Text("Sapi"),
                                    leading: SizedBox(
                                      width: 150,
                                      height: 75,
                                      child: FutureBuilder(
                                        future: getImageFromStorage(data['gambar_1'], dataList[index]['kategori']),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData) {
                                            return Image.network(
                                              snapshot.data!,
                                              width: 150,
                                              height: 75,
                                              fit: BoxFit.contain,
                                            );
                                          }
                                          if (snapshot.hasError) {
                                            return Text("Terjadi Kesalahan");
                                          }
                                          return Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        },
                                      ),
                                    ),
                                    subtitle: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Row(
                                              children: [
                                                Image.asset(
                                                  "assets/icon_umur.png",
                                                  height: 20,
                                                ),
                                                Text(
                                                  "${data['usia']}",
                                                )
                                              ],
                                            ),
                                            SizedBox(
                                              width: 25,
                                            ),
                                            Row(
                                              children: [
                                                Image.asset("assets/icon_tinggi.png", height: 20),
                                                Text("${data['tinggi']}")
                                              ],
                                            ),
                                            SizedBox(
                                              width: 25,
                                            ),
                                            Row(
                                              children: [
                                                Image.asset("assets/icon_bobot.png", height: 20),
                                                Text("${data['berat']}")
                                              ],
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Row(
                                          children: [
                                            Row(
                                              children: [
                                                Image.asset("assets/icon_harga.png", height: 20),
                                                Text(
                                                  "${currencyFormatter.format(data['harga'])}",
                                                  maxLines: 3,
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                }
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              });
                        },
                      ).toList(),
                    );
                  },
                );
              }
              if (snapshot.hasData) {
                return Center(
                  child: Text("Kosong"),
                );
              }
              return Center(
                child: CircularProgressIndicator(),
              );
            },
          ),
        ),
      ],
    );
  }
}
