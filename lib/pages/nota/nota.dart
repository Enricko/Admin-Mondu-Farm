import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:pagination_flutter/pagination.dart';

import '../../utils/alerts.dart';
import '../../utils/color.dart';
import '../booking/edit_nota.dart';
import '../booking/kirim_nota.dart';

class NotaTable extends StatefulWidget {
  const NotaTable({Key? key}) : super(key: key);

  @override
  State<NotaTable> createState() => _NotaTableState();
}

class _NotaTableState extends State<NotaTable> {
  final _formKey = GlobalKey<FormState>();
  DatabaseReference db = FirebaseDatabase.instance.ref().child('nota');

  int page = 1;
  int perpage = 10;

  incrementPage(int pageIndex) {
    setState(() {
      page = pageIndex;
    });
  }

  void accNota(Map<dynamic, dynamic> dataId,BuildContext context) {
    var data = {
      "kategori": dataId['kategori'],
      "id_ternak": dataId['id_ternak'],
      "id_booking": dataId['id_booking'],
      "id_user": dataId['id_user'],
      "id_nota": dataId['id_nota'],
    };
    Nota.accNota(data, context);
  }

  // Future<void> notaExpiredIf2Days() async {
  //   await FirebaseDatabase.instance.ref().child('nota').get().then((value) {
  //     Map<dynamic, dynamic> dataTernak = value.value as Map<dynamic, dynamic>;
  //     dataTernak.entries.forEach((element) async {
  //       if (DateTime.parse(element.value['tanggal_booking'].toString())
  //           .add(Duration(days: 2))
  //           .isBefore(DateTime.now())) {
  //         await FirebaseDatabase.instance.ref().child("booking").child(element.key).remove();
  //       }
  //     });
  //     setState(() {});
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          alignment: Alignment.centerLeft,
          child: Text(
            "Table Nota",
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
              List<Map<dynamic, dynamic>> dataList = [];
              data.forEach((key, value) {
                // Map<dynamic, dynamic> dataValue = value as Map<dynamic, dynamic>;
                value.forEach((key1, value1) {
                  final currentData = Map<String, dynamic>.from(value1);
                  dataList.add({
                    'nama': currentData['nama'],
                    'no_telepon': currentData['no_telepon'],
                    'urlGambar': currentData['urlGambar'],
                    'kategori': currentData['kategori'],
                    'id_ternak': currentData['id_ternak'],
                    'id_booking': currentData['id_booking'],
                    'id_user': currentData['id_user'],
                    'id_nota': key1,
                    'tanggal_booking': currentData['tanggal_booking'],
                  });
                });
              });
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
                                  DataColumn(label: Text("Keterangan")),
                                  // DataColumn(label: Text("Kategori")),
                                  // DataColumn(label: Text("Action")),
                                ],
                                rows: buildDataRows(dataList)

                                // return DataRow(
                                //   cells: [
                                //     DataCell(Text()),
                                //     DataCell(Text()),
                                //     DataCell(Text()),
                                //     DataCell(Text(
                                //         val.value['kategori']!.toString())),
                                //     DataCell(
                                //       Row(
                                //         children: [
                                //           Tooltip(
                                //               message: "Edit Nota",
                                //               child: ElevatedButton(
                                //                   onPressed: () {
                                //                     showDialog(
                                //                       context: context,
                                //                       barrierDismissible:
                                //                           false,
                                //                       builder: (BuildContext
                                //                           context) {
                                //                         return Dialog(
                                //                           shape: const RoundedRectangleBorder(
                                //                               borderRadius: BorderRadius
                                //                                   .all(Radius
                                //                                       .circular(
                                //                                           5))),
                                //                           child: EditNota(
                                //                             id_booking:
                                //                                 val.key!,
                                //                             id_ternak: val
                                //                                 .value[
                                //                                     'id_ternak']!
                                //                                 .toString(),
                                //                             id_user: val
                                //                                 .value[
                                //                                     'id_user']!
                                //                                 .toString(),
                                //                             kategori: val
                                //                                 .value[
                                //                                     'kategori']!
                                //                                 .toString(),
                                //                             nama: val.value[
                                //                                     'nama']!
                                //                                 .toString(),
                                //                             noTelepon: val
                                //                                 .value[
                                //                                     'no_telepon']!
                                //                                 .toString(),
                                //                             tanggalBooking: val
                                //                                 .value[
                                //                                     'tanggal_booking']!
                                //                                 .toString(),
                                //                           ),
                                //                         );
                                //                       },
                                //                     );
                                //                   },
                                //                   child: Text("Edit Nota"))),
                                //         ],
                                //       ),
                                //     ),
                                //   ],
                                // );
                                // },
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

  List<DataRow> buildDataRows(List<Map<dynamic, dynamic>> dataList) {
    List<DataRow> dataRows = [];
    for (int i = 0; i < dataList.length; i++) {
      dataRows.add(
        DataRow(
          cells: [
            DataCell(Text("${i + 1}")),
            DataCell(Text(dataList[i]['nama'].toString())),
            DataCell(Text(dataList[i]['no_telepon'].toString())),
            DataCell((DateTime.parse(dataList[i]['tanggal_booking'].toString())
                        .add(Duration(days: 2))
                        .isBefore(DateTime.now()))
                    ? Text("Expired")
                    : ElevatedButton(
                        onPressed: () {
                          var data = ({
                            'kategori' : dataList[i]['kategori'],
                            'id_ternak' : dataList[i]['id_ternak'],
                            'id_booking' : dataList[i]['id_booking'],
                            'id_user' : dataList[i]['id_user'],
                            'id_nota' : dataList[i]['id_nota'],
                          });
                          accNota(
                            data,
                              context);
                        },
                        child: Text("Ternak Sudah Di Ambil"))
                // Text(dataList[i]['no_telepon'].toString())
                ),
            // DataCell(Text(dataList[i][''])),
          ],
        ),
      );
    }

    return dataRows;
  }
}
