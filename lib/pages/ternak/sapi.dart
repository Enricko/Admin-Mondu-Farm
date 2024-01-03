import 'dart:async';
import 'dart:math';

import 'package:admin_mondu_farm/pages/ternak/sapi/insert_form.dart';
import 'package:admin_mondu_farm/utils/alerts.dart';
import 'package:admin_mondu_farm/utils/color.dart';
import 'package:admin_mondu_farm/utils/custom_extension.dart';
import 'package:admin_mondu_farm/utils/text_field.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pagination_flutter/pagination.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class SapiTable extends StatefulWidget {
  const SapiTable({super.key});

  @override
  State<SapiTable> createState() => _SapiTableState();
}

class _SapiTableState extends State<SapiTable> {
  DatabaseReference db = FirebaseDatabase.instance.ref().child('ternak').child("sapi");
  int page = 1;
  int perpage = 10;

  incrementPage(int pageIndex) {
    setState(() {
      page = pageIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          alignment: Alignment.centerLeft,
          child: Text(
            "Table Sapi",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
          ),
        ),
        SizedBox(
          height: 15,
        ),
        ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Warna.biruUngu),
            foregroundColor: MaterialStateProperty.all(Colors.black),
          ),
          onPressed: () async {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return Dialog(
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                  child: AddTernakForm(width: width),
                );
              },
            );
          },
          child: Text("Tambah Data"),
        ),
        SizedBox(
          height: 25,
        ),
        StreamBuilder(
          stream: db.onValue,
          builder: (context, snapshot) {
            if (snapshot.hasData && (snapshot.data!).snapshot.value != null) {
              // Variable data mempermudah memanggil data pada database
              Map<dynamic, dynamic> data =
                  Map<dynamic, dynamic>.from((snapshot.data! as DatabaseEvent).snapshot.value as Map<dynamic, dynamic>);
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
                                headingRowColor: MaterialStateProperty.all(const Color(0xffd3d3d3)),
                                dataRowColor: MaterialStateProperty.all(const Color(0xffd3d3d3).withOpacity(0.7)),
                                border: TableBorder.all(width: 1, color: Colors.black),
                                columns: const [
                                  DataColumn(label: Text("No")),
                                  DataColumn(label: Text("Gambar")),
                                  DataColumn(label: Text("Usia")),
                                  DataColumn(label: Text("Tinggi")),
                                  DataColumn(label: Text("Berat")),
                                  DataColumn(label: Text("Harga")),
                                  DataColumn(label: Text("Action")),
                                ],
                                rows: data.entries.skip((page - 1) * perpage).take(perpage).map((val) {
                                  var numberedTable = data.entries.toList().indexWhere(
                                          (element) => element.value == val.value && element.key == val.key) +
                                      1;
                                  return DataRow(cells: [
                                    DataCell(Text(numberedTable.toString())),
                                    DataCell(Text(val.value['gambar'])),
                                    DataCell(Text(val.value['usia']!.toString())),
                                    DataCell(Text(val.value['tinggi']!.toString())),
                                    DataCell(Text(val.value['berat']!.toString())),
                                    DataCell(Text(val.value['harga']!.toString())),
                                    DataCell(Row(
                                      children: [
                                        Tooltip(
                                          message: "Edit",
                                          child: IconButton(
                                            icon: const Icon(
                                              Icons.edit,
                                              color: Colors.blue,
                                            ),
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                barrierDismissible: false,
                                                builder: (BuildContext context) {
                                                  return Dialog(
                                                    shape: const RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.all(Radius.circular(5))),
                                                    // child: EditUserForm(
                                                    //   width: width,
                                                    //   formKey: _formKey,
                                                    //   id: val.key,
                                                    //   data: val.value,
                                                    // ),
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                        ),
                                        Tooltip(
                                          message: "Delete",
                                          child: IconButton(
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                            onPressed: () {
                                              Alerts.showAlertYesNo(
                                                title: "Are you sure you want to delete this data?",
                                                onPressYes: () async {
                                                  db.child(val.key).remove();
                                                  EasyLoading.showSuccess("Data berhasil di hapus.",
                                                      dismissOnTap: true, duration: Duration(seconds: 3));
                                                  Navigator.pop(context);
                                                },
                                                onPressNo: () {
                                                  Navigator.pop(context);
                                                },
                                                context: context,
                                              );
                                            },
                                          ),
                                        ),
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
                          backgroundColor: MaterialStateProperty.all(Warna.ungu),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(38),
                            ),
                          ),
                        ),
                        inactiveBtnStyle: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Warna.biruUngu),
                          shape: MaterialStateProperty.all(RoundedRectangleBorder(
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
                              headingRowColor: MaterialStateProperty.all(const Color(0xffd3d3d3)),
                              dataRowColor: MaterialStateProperty.all(const Color(0xffd3d3d3).withOpacity(0.7)),
                              border: TableBorder.all(width: 1, color: Colors.black),
                              columns: const [
                                DataColumn(label: Text("No")),
                                DataColumn(label: Text("Gambar")),
                                DataColumn(label: Text("Usia")),
                                DataColumn(label: Text("Tinggi")),
                                DataColumn(label: Text("Berat")),
                                DataColumn(label: Text("Harga")),
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
                          backgroundColor: MaterialStateProperty.all(Warna.ungu),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(38),
                            ),
                          ),
                        ),
                        inactiveBtnStyle: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Warna.biruUngu),
                          shape: MaterialStateProperty.all(RoundedRectangleBorder(
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
