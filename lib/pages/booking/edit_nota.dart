import 'dart:async';

import 'package:admin_mondu_farm/utils/constants.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../system/auth.dart';
import '../../utils/color.dart';
import '../../utils/text_field.dart';
import '../login.dart';
import 'kirim_nota.dart';

class EditNota extends StatefulWidget {
  final String id_ternak;
  final String id_user;
  final String kategori;
  final String nama;
  final String noTelepon;
  final String tanggalBooking;

  const EditNota(
      {super.key,
      required this.id_ternak,
      required this.kategori,
      required this.nama,
      required this.noTelepon, required this.tanggalBooking, required this.id_user});

  @override
  State<EditNota> createState() => _EditNotaState();
}

class _EditNotaState extends State<EditNota> {
  TextEditingController umurController = TextEditingController();
  TextEditingController beratController = TextEditingController();
  TextEditingController tinggiController = TextEditingController();
  TextEditingController hargaController = TextEditingController();

  String? umur;
  String? berat;
  String? tinggi;
  String? urlGambar;
  final _formKey = GlobalKey<FormState>();
  bool ignorePointer = false;
  Timer? ignorePointerTimer;

  void cekUser() async {
    await FirebaseAuth.instance.currentUser;
    // Logic cek Data User apakah sudah pernah login
    if (FirebaseAuth.instance.currentUser == null) {
      FirebaseAuth.instance.currentUser;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => LoginPage()));
      });
    }
  }
  NumberFormat currencyFormatter = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  Future<void> getUserFromFirebase() async {
    print(widget.kategori);
    print(widget.id_ternak);
    try {
      FirebaseDatabase.instance
          .ref()
          .child("ternak")
          .child(widget.kategori)
          .child(widget.id_ternak)
          .onValue
          .listen((event) {
        var snapshot = event.snapshot.value as Map;
        setState(() {
          umur = snapshot['usia'].toString();
          berat = snapshot['berat'].toString();
          tinggi = snapshot['tinggi'].toString();
          hargaController.text = currencyFormatter.format(snapshot['harga']);
          urlGambar = snapshot['gambar'].toString();
        });
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<String> getImageFromStorage(String pathName) {
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage
        .ref()
        .child("ternak")
        .child(widget.kategori.toLowerCase())
        .child(widget.id_ternak)
        .child(pathName);
    return ref.getDownloadURL();
  }

  void kirimNota(BuildContext context) {
    var data = {
      "nama": widget.nama,
      "no_telepon": widget.noTelepon,
      "urlGambar": urlGambar,
      "tanggal_booking": widget.tanggalBooking,
      "umur": umur,
      "berat": berat,
      "tinggi": tinggi,
      "harga": hargaController.text,
    };
    Nota.kirimNota(data,widget.id_user,context);
  }

  @override
  void initState() {
    super.initState();
    cekUser();
    getUserFromFirebase();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Container(
      width: width <= 540 ? width / 1.3 : width / 2,
      decoration: BoxDecoration(
        color: Warna.latar,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Warna.biruUngu,
              ),
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Edit Nota",
                    style: GoogleFonts.openSans(
                        fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Container(
              // height: 485,
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // FutureBuilder(
                            //   future: getImageFromStorage(urlGambar!),
                            //   builder: (context, snapshot) {
                            //     if (snapshot.hasData) {
                            //       return Image.network(snapshot.data!,
                            //           fit: BoxFit.fill);
                            //     }
                            //     if (snapshot.hasError) {
                            //       return Text("Terjadi Kesalahan");
                            //     }
                            //     return Center(
                            //       child: CircularProgressIndicator(),
                            //     );
                            //   },
                            // ),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Nama",
                                      style: Constants.labelstyle,
                                    ),
                                    Text(
                                      "Nomor Telepon",
                                      style: Constants.labelstyle,
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "=",
                                      style: Constants.labelstyle,
                                    ),
                                    Text(
                                      "=",
                                      style: Constants.labelstyle,
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.nama,
                                      style: Constants.labelstyle,
                                    ),
                                    Text(
                                      widget.noTelepon,
                                      style: Constants.labelstyle,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Divider(
                              color: Colors.black,
                            ),
                            Text("Deskripsi Ternak",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                            FutureBuilder(
                              future: getImageFromStorage(urlGambar!),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Card(
                                          child: Image.network(snapshot.data!,
                                              fit: BoxFit.fill)
                                      );
                                }
                                if (snapshot.hasError) {
                                  return Image.asset("assets/gambar/placeholder.png",width: double.infinity,);
                                }
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                            ),
                            // Text("Berat Ternak = $berat Kg",
                            //     style: Constants.labelstyle),
                            Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Umur Ternak",
                                      style: Constants.labelstyle,
                                    ),
                                    Text(
                                      "Berat Ternak",
                                      style: Constants.labelstyle,
                                    ),
                                    Text(
                                      "Tinggi Ternak",
                                      style: Constants.labelstyle,
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "=",
                                      style: Constants.labelstyle,
                                    ),
                                    Text(
                                      "=",
                                      style: Constants.labelstyle,
                                    ),
                                    Text(
                                      "=",
                                      style: Constants.labelstyle,
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${umur} Tahun",
                                      style: Constants.labelstyle,
                                    ),
                                    Text(
                                      "${berat} Kg",
                                      style: Constants.labelstyle,
                                    ),
                                    Text(
                                      "${tinggi} Meter",
                                      style: Constants.labelstyle,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Divider(color: Colors.black,),
                            Text(
                              "Harga Ternak",
                              style: Constants.labelstyle,
                            ),
                            TextFormField(
                              controller: hargaController,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty || value == "") {
                                  return "Harga harus di isi!";
                                }
                                return null;
                              },
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10),
                                CurrencyTextInputFormatter(
                                  locale: 'ID',
                                  decimalDigits: 0,
                                  symbol: 'Rp. ',
                                ),
                              ],
                              // readOnly: true,
                              decoration: InputDecoration(
                                filled: true,
                                // enabled: false,
                                fillColor: const Color(0xFFFCFDFE),
                                hintText: "Harga Ternak",
                                hintStyle: const TextStyle(
                                  color: Color(0xFF696F79),
                                  fontSize: 14,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w400,
                                ),
                                isDense: true,
                                contentPadding: const EdgeInsets.fromLTRB(
                                    15, 30, 15, 0),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(13),
                                  borderSide: const BorderSide(
                                      width: 1, color: Color(0xFFDEDEDE)),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      width: 1, color: Colors.redAccent),
                                  borderRadius: BorderRadius.circular(13),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 5,),
                      SizedBox(
                        width: double.infinity,
                        child: IgnorePointer(
                          ignoring: ignorePointer,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Warna.ungu),
                              shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            ),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                // Prevent Multiple Clicked
                                setState(() {
                                  ignorePointer = true;
                                  ignorePointerTimer =
                                      Timer(const Duration(seconds: 3), () {
                                    setState(() {
                                      ignorePointer = false;
                                    });
                                  });
                                });
                                kirimNota(context);
                              }
                            },
                            child: const Text(
                              "Kirim Nota",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
