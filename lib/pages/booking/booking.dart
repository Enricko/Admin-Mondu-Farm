import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:pagination_flutter/pagination.dart';

import '../../utils/alerts.dart';
import '../../utils/color.dart';
import 'edit_nota.dart';

class BookingTable extends StatefulWidget {
  const BookingTable({Key? key}) : super(key: key);

  @override
  State<BookingTable> createState() => _BookingTableState();
}

class _BookingTableState extends State<BookingTable> {
  final _formKey = GlobalKey<FormState>();
  DatabaseReference db = FirebaseDatabase.instance.ref().child('booking');

  int page = 1;
  int perpage = 10;

  incrementPage(int pageIndex) {
    setState(() {
      page = pageIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          alignment: Alignment.centerLeft,
          child: Text(
            "Table Booking",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
          ),
        ),
        SizedBox(
          height: 15,
        ),
        StreamBuilder(
          stream: db.onValue,
          builder: (context, snapshot) {
            if (snapshot.hasData && (snapshot.data!).snapshot.value != null) {
              Map<dynamic, dynamic> data = Map<dynamic, dynamic>.from(
                  (snapshot.data!).snapshot.value as Map<dynamic, dynamic>);
              // data.removeWhere((key, value) => value['level'] == null || value['level'] == "user");
              return Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        alignment: Alignment.topCenter,
                        margin: const EdgeInsets.symmetric(horizontal: 15),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SingleChildScrollView(
                            child: DataTable(
                                headingRowColor: MaterialStateProperty.all(
                                    const Color(0xffd3d3d3)),
                                dataRowColor: MaterialStateProperty.all(
                                    const Color(0xffd3d3d3).withOpacity(0.7)),
                                border: TableBorder.all(
                                    width: 1, color: Colors.black),
                                columns: const [
                                  DataColumn(label: Text("No")),
                                  DataColumn(label: Text("Nama")),
                                  DataColumn(label: Text("No Telepon")),
                                  DataColumn(label: Text("Kategori")),
                                  DataColumn(label: Text("Tanggal")),
                                  DataColumn(label: Text("Action")),
                                ],
                                rows: data.entries
                                    .where((element) =>
                                        element.value['status_booking'] ==
                                        "Sedang Di Booking")
                                    .skip((page - 1) * perpage)
                                    .take(perpage)
                                    .map((val) {
                                  var numberedTable = data.entries
                                          .toList()
                                          .indexWhere((element) =>
                                              element.value == val.value &&
                                              element.key == val.key) +
                                      1;
                                  // List<Map<dynamic, dynamic>> filteredList = val
                                  //     .where((entry) => entry['id_user'] == id_user)
                                  //     .toList();
                                  // var id_booking = data.entries.
                                  // print(val.key);

                                  return DataRow(cells: [
                                    DataCell(Text(numberedTable.toString())),
                                    // DataCell(Text(dataList)),
                                    DataCell(
                                        Text(val.value['nama']!.toString())),
                                    DataCell(Text(
                                        val.value['no_telepon']!.toString())),
                                    DataCell(Text(
                                        val.value['kategori']!.toString())),
                                    DataCell(Text(val.value['tanggal_booking']!
                                        .toString())),
                                    DataCell(Row(
                                      children: [
                                        Tooltip(
                                            message: "Edit Nota",
                                            child: ElevatedButton(
                                                onPressed: () {
                                                  showDialog(
                                                    context: context,
                                                    barrierDismissible: false,
                                                    builder:
                                                        (BuildContext context) {
                                                      return Dialog(
                                                        shape: const RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            5))),
                                                        child: EditNota(
                                                          id_booking: val.key!,
                                                          id_ternak: val.value[
                                                                  'id_ternak']!
                                                              .toString(),
                                                          id_user: val
                                                              .value['id_user']!
                                                              .toString(),
                                                          kategori: val.value[
                                                                  'kategori']!
                                                              .toString(),
                                                          nama: val
                                                              .value['nama']!
                                                              .toString(),
                                                          noTelepon: val.value[
                                                                  'no_telepon']!
                                                              .toString(),
                                                          tanggalBooking: val
                                                              .value[
                                                                  'tanggal_booking']!
                                                              .toString(),
                                                        ),
                                                      );
                                                    },
                                                  );
                                                },
                                                child: Text("Edit Nota"))),
                                      ],
                                    )),
                                  ]);
                                }).toList()),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 50,
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 15),
                      child: Pagination(
                        numOfPages: ((data.length) / perpage).ceil(),
                        selectedPage: page,
                        pagesVisible: 5,
                        onPageChanged: (value) {
                          if (value != page) {
                            incrementPage(value);
                          }
                        },
                        nextIcon: const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.black,
                          size: 14,
                        ),
                        previousIcon: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.black,
                          size: 14,
                        ),
                        activeTextStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                        activeBtnStyle: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Warna.ungu),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(38),
                            ),
                          ),
                        ),
                        inactiveBtnStyle: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Warna.biruUngu),
                          shape:
                              MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(38),
                          )),
                        ),
                        inactiveTextStyle: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            if (snapshot.hasData) {
              return Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        alignment: Alignment.topCenter,
                        margin: const EdgeInsets.symmetric(horizontal: 15),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SingleChildScrollView(
                            child: DataTable(
                              headingRowColor: MaterialStateProperty.all(
                                  const Color(0xffd3d3d3)),
                              dataRowColor: MaterialStateProperty.all(
                                  const Color(0xffd3d3d3).withOpacity(0.7)),
                              border: TableBorder.all(
                                  width: 1, color: Colors.black),
                              columns: const [
                                DataColumn(label: Text("No")),
                                DataColumn(label: Text("Nama")),
                                DataColumn(label: Text("No Telepon")),
                                DataColumn(label: Text("Action")),
                              ],
                              rows: [],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 50,
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 15),
                      child: Pagination(
                        numOfPages: ((1) / perpage).ceil(),
                        selectedPage: page,
                        pagesVisible: 5,
                        onPageChanged: (value) {
                          if (value != page) {
                            incrementPage(value);
                          }
                        },
                        nextIcon: const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.black,
                          size: 14,
                        ),
                        previousIcon: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.black,
                          size: 14,
                        ),
                        activeTextStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                        activeBtnStyle: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Warna.ungu),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(38),
                            ),
                          ),
                        ),
                        inactiveBtnStyle: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Warna.biruUngu),
                          shape:
                              MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(38),
                          )),
                        ),
                        inactiveTextStyle: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return Expanded(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          },
        ),
      ],
    );
  }
}
