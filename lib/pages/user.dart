import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart' as intl;

class UserTable extends StatefulWidget {
  const UserTable({super.key});

  @override
  State<UserTable> createState() => _UserTableState();
}

class _UserTableState extends State<UserTable> {
  DatabaseReference db = FirebaseDatabase.instance.ref().child('users');
  var perPageSelected = 10;
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Column(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          child: Text(
            "Table User",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
          ),
        ),
        SizedBox(
          height: 25,
        ),
        StreamBuilder(
          stream: db.onValue,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              // Variable data mempermudah memanggil data pada database
              Map<dynamic, dynamic> data =
                  Map<dynamic, dynamic>.from((snapshot.data! as DatabaseEvent).snapshot.value as Map<dynamic, dynamic>);
              return Container(
                alignment: Alignment.center,
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 15),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: DataTable(
                        headingRowColor: MaterialStateProperty.all(const Color(0xffd3d3d3)),
                        dataRowColor: MaterialStateProperty.all(const Color(0xffd3d3d3).withOpacity(0.7)),
                        border: TableBorder.all(width: 1,color: Colors.black),
                        columns: const [
                          DataColumn(label: Text("No")),
                          DataColumn(label: Text("Nama")),
                          DataColumn(label: Text("Email")),
                          DataColumn(label: Text("No Telphone")),
                          DataColumn(label: Text("Action")),
                        ],
                        rows: data.entries.map((val) {
                          var numberedTable = data.entries.toList().indexWhere((element) => element.value == val.value && element.key == val.key) + 1;
                          return DataRow(cells: [
                            DataCell(Text(numberedTable.toString())),
                            DataCell(Text(val.value['nama'])),
                            DataCell(Text(val.value['email']!)),
                            DataCell(Text(val.value['no_telpon']!.toString())),
                            DataCell(Text(val.value['no_telpon']!.toString())),
                          ]);
                        }).toList()),
                  ),
                ),
              );
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ],
    );
  }
}
