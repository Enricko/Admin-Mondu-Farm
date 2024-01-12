import 'dart:async';

import 'package:admin_mondu_farm/pages/main_page.dart';
import 'package:admin_mondu_farm/utils/audio_chat/audio_chat_widget.dart';
import 'package:admin_mondu_farm/utils/audio_chat/record_chat_widget.dart';
import 'package:admin_mondu_farm/utils/color.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data' show Uint8List;

import 'package:intl/intl.dart';

typedef _Fn = void Function();

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.idUser});
  final String idUser;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  Future<Map<dynamic, dynamic>>? dataUser;
  @override
  void initState() {
    super.initState();
    setState(() {
      dataUser = FirebaseDatabase.instance
          .ref()
          .child("users")
          .child("${widget.idUser}")
          .get()
          .then((value) => value.value as Map<dynamic, dynamic>);
    });
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return FutureBuilder(
      future: dataUser,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
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
                    const SizedBox(
                      width: 15,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${snapshot.data!['nama']}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                        Text(
                          "${snapshot.data!['no_telepon']}",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: Warna.biruUngu,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: StreamBuilder(
                    stream: FirebaseDatabase.instance.ref().child("pesan").child("-NnJThg-A5k5iNE8Z1VT").onValue,
                    builder: (context, snapshot) {
                      if (snapshot.hasData && (snapshot.data!).snapshot.value != null) {
                        // Variable data mempermudah memanggil data pada database
                        Map<dynamic, dynamic> data = Map<dynamic, dynamic>.from(
                            (snapshot.data! as DatabaseEvent).snapshot.value as Map<dynamic, dynamic>);

                        List<Map<dynamic, dynamic>> dataList = [];
                        data.forEach((key, value) {
                          final currentData = Map<String, dynamic>.from(value);
                          dataList.add({
                            'uid': key,
                            'durasi': currentData['durasi'],
                            'pesan': currentData['pesan'],
                            'pesan_dari': currentData['pesan_dari'],
                            'tanggal': currentData['tanggal'],
                            'type': currentData['type'],
                          });
                        });
                        dataList.sort((a, b) {
                          var aDate = DateTime.parse(a["tanggal"]);
                          var bDate = DateTime.parse(b["tanggal"]);
                          return aDate.compareTo(bDate);
                        });
                        return SingleChildScrollView(
                          reverse: true,
                          child: Column(
                              children: dataList.map((e) {
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 15),
                              child: Row(
                                mainAxisAlignment:
                                    e['pesan_dari'] == "admin" ? MainAxisAlignment.end : MainAxisAlignment.start,
                                children: <Widget>[
                                  AudioChatWidget(data: e)
                                ],
                              ),
                            );
                          }).toList()),
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
              RecordChatWidget(
                idUser: widget.idUser,
              ),
            ],
          );
        }
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  double durationStringToDouble(String durasi) {
    double durationDouble = 1.0;
    String durationString = durasi; // Example duration string in mm:ss:SS format

    List<String> parts = durationString.split(':');

    // Assuming the string format is "mm:ss:SS"
    int minutes = int.parse(parts[0]);
    int seconds = int.parse(parts[1]);
    int milliseconds = int.parse(parts[2]);

    // Convert the duration to a double representation in milliseconds
    durationDouble = (minutes * 60 * 1000) + (seconds * 1000) + milliseconds as double;
    return durationDouble;
  }

}
