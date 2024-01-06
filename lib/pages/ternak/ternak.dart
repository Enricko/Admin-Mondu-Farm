import 'dart:async';

import 'package:admin_mondu_farm/pages/login.dart';
import 'package:admin_mondu_farm/pages/ternak/insert_form.dart';
import 'package:admin_mondu_farm/pages/ternak/update_form.dart';
import 'package:admin_mondu_farm/utils/alerts.dart';
import 'package:admin_mondu_farm/utils/color.dart';
import 'package:admin_mondu_farm/utils/custom_extension.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pagination_flutter/pagination.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class TableTernak extends StatefulWidget {
  const TableTernak({super.key, required this.kategori});
  final String kategori;

  @override
  State<TableTernak> createState() => _TableTernakState();
}

class _TableTernakState extends State<TableTernak> {
  DatabaseReference db = FirebaseDatabase.instance.ref().child('ternak');

  int page = 1;
  int perpage = 10;
  NumberFormat currencyFormatter = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  incrementPage(int pageIndex) {
    setState(() {
      page = pageIndex;
    });
  }

  Future<String> getImageFromStorage(String pathName) {
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage.ref().child("ternak").child(widget.kategori.toLowerCase()).child(pathName);

    return ref.getDownloadURL();
  }

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          alignment: Alignment.centerLeft,
          child: Text(
            "Table ${widget.kategori.title()}",
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
                  child: InsertTernakForm(width: width, kategori: widget.kategori.toLowerCase()),
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
          stream: db.child(widget.kategori.toLowerCase()).onValue,
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
                                dataRowHeight: 100,
                                rows: data.entries.skip((page - 1) * perpage).take(perpage).map((val) {
                                  var numberedTable = data.entries.toList().indexWhere(
                                          (element) => element.value == val.value && element.key == val.key) +
                                      1;

                                  return DataRow(cells: [
                                    DataCell(Text(numberedTable.toString())),
                                    DataCell(
                                      FutureBuilder<String>(
                                        future: getImageFromStorage(val.value['gambar']),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData) {
                                            return Container(
                                              margin: EdgeInsets.all(5),
                                              child: Image.network(
                                                snapshot.data!,
                                                width: 150,
                                              ),
                                            );
                                          }

                                          return Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        },
                                      ),
                                    ),
                                    DataCell(Text(val.value['usia'].toString())),
                                    DataCell(Text(val.value['tinggi'].toString())),
                                    DataCell(Text(val.value['berat'].toString())),
                                    DataCell(Text(currencyFormatter.format(val.value['harga']))),
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
                                                    child: EditTernakForm(
                                                      width: width,
                                                      kategori: widget.kategori.toLowerCase(),
                                                      id: val.key,
                                                      data: val.value,
                                                    ),
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
                                                  EasyLoading.show(status: "Loading...");
                                                  FirebaseStorage.instance
                                                      .ref()
                                                      .child("ternak")
                                                      .child(widget.kategori.toLowerCase())
                                                      .child(val.value['gambar'])
                                                      .delete()
                                                      .whenComplete(() {
                                                    db
                                                        .child(widget.kategori.toLowerCase())
                                                        .child(val.key)
                                                        .remove()
                                                        .whenComplete(() {
                                                      EasyLoading.showSuccess("Data berhasil di hapus.",
                                                          dismissOnTap: true, duration: Duration(seconds: 3));
                                                      Navigator.pop(context);
                                                    }).onError((error, stackTrace) {
                                                      EasyLoading.showSuccess("Error : ${error}.",
                                                          dismissOnTap: true, duration: Duration(seconds: 3));
                                                    });
                                                  }).onError((error, stackTrace) {
                                                    EasyLoading.showSuccess("Error : ${error}.",
                                                        dismissOnTap: true, duration: Duration(seconds: 3));
                                                  });
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
