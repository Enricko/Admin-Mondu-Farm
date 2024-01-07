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

typedef _Fn = void Function();

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.uid});
  final String uid;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
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
              const Text(
                "Nama",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
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
                    // Setiap data yang di perulangkan bakal di simpan ke dalam list
                    final currentData = Map<String, dynamic>.from(value);
                    // Mensetting variable dengan total lembur dan gaji)
                    dataList.add({
                      'uid': key,
                      'pesan': currentData['pesan'],
                      'tanggal': currentData['tanggal'],
                      'type': currentData['type'],
                    });
                  });
                  return ListView.builder(
                    itemCount: dataList.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 15),
                        child: Row(
                          mainAxisAlignment: index % 2 == 0 ? MainAxisAlignment.end : MainAxisAlignment.start,
                          children: <Widget>[AudioChatWidget(data: dataList[index])],
                        ),
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
        const RecordChatWidget(),
      ],
    );
  }
}
