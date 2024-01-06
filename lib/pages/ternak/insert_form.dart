import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:admin_mondu_farm/pages/login.dart';
import 'package:admin_mondu_farm/utils/color.dart';
import 'package:admin_mondu_farm/utils/custom_extension.dart';
import 'package:admin_mondu_farm/utils/text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import "package:firebase_storage/firebase_storage.dart";
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';

class InsertTernakForm extends StatefulWidget {
  const InsertTernakForm({
    super.key,
    required this.width,
    required this.kategori,
  });

  final String kategori;
  final double width;

  @override
  State<InsertTernakForm> createState() => _InsertTernakFormState();
}

class _InsertTernakFormState extends State<InsertTernakForm> {
  DatabaseReference db = FirebaseDatabase.instance.ref().child('ternak').child("sapi");
  TextEditingController usiaController = TextEditingController();
  TextEditingController tinggiController = TextEditingController();
  TextEditingController beratController = TextEditingController();
  TextEditingController hargaController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool ignorePointer = false;
  Timer? ignorePointerTimer;

  File? file;
  ImagePicker image = ImagePicker();
  Uint8List webImage = Uint8List(8);
  var url;

  getImage() async {
    XFile? img = await image.pickImage(source: ImageSource.gallery);
    var f = await img!.readAsBytes();
    setState(() {
      webImage = f;
      file = File(img.path);
    });
  }

  insertData() async {
    try {
      if (webImage.isNotEmpty && file != null) {
        var metadata = SettableMetadata(
          contentType: "image/jpeg",
        );
        String imageName = "${generateRandomString(10)}-${DateTime.now()}.png";
        var imagefile = FirebaseStorage.instance
            .ref()
            .child("ternak")
            .child(widget.kategori.toString().toLowerCase())
            .child(imageName);

        if (!kIsWeb) {
          imagefile.putFile(file!, metadata);
        } else {
          imagefile.putData(webImage, metadata);
        }
        Map<String, dynamic> val = {
          'usia': int.parse(usiaController.text),
          "tinggi": int.parse(tinggiController.text),
          "berat": int.parse(beratController.text),
          "harga": int.parse(hargaController.text.replaceAll(RegExp(r'[^0-9]'), '')),
          'gambar': imageName,
        };

        FirebaseDatabase.instance
            .ref()
            .child("ternak")
            .child(widget.kategori.toString().toLowerCase())
            .push()
            .set(val)
            .whenComplete(() {
          EasyLoading.showSuccess('Sapi telah di tambahkan', dismissOnTap: true, duration: Duration(seconds: 3));
          Navigator.pop(context);
          return;
        });
      } else {
        EasyLoading.showError('Mohon Gambarnya di isi', dismissOnTap: true, duration: Duration(seconds: 3));
      }
    } on Exception catch (e) {
      EasyLoading.showError('Error : ${e}', dismissOnTap: true, duration: Duration(seconds: 3));
      print(e);
    }
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
  void dispose() {
    super.dispose();

    if (ignorePointerTimer != null) {
      ignorePointerTimer!.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width <= 540 ? widget.width / 1.3 : widget.width / 1.6,
      decoration: BoxDecoration(
        color: Warna.latar,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
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
                  "Tambah Ternak ${widget.kategori.toString().title()}",
                  style: GoogleFonts.openSans(fontSize: 15, fontWeight: FontWeight.bold),
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
            height: 485,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 5,
                          ),
                          Center(
                            child: Container(
                              height: 200,
                              width: 200,
                              child: file == null
                                  ? Tooltip(
                                      message: "Upload Image",
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.add_a_photo,
                                          size: 90,
                                          color: Color.fromARGB(255, 179, 179, 179),
                                        ),
                                        onPressed: () {
                                          getImage();
                                        },
                                      ),
                                    )
                                  : MaterialButton(
                                      height: 100,
                                      child: kIsWeb
                                          ? Image.memory(
                                              webImage,
                                              fit: BoxFit.fill,
                                            )
                                          : Image.file(
                                              file!,
                                              fit: BoxFit.fill,
                                            ),
                                      onPressed: () {
                                        getImage();
                                      },
                                    ),
                            ),
                          ),
                          CustomTextField(
                            controller: usiaController,
                            hint: "Usia",
                            type: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                          CustomTextField(
                            controller: tinggiController,
                            hint: "Tinggi",
                            type: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                          CustomTextField(
                            controller: beratController,
                            hint: "Berat",
                            type: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                          CustomTextField(
                            controller: hargaController,
                            hint: "Harga",
                            type: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                              CurrencyTextInputFormatter(
                                locale: 'ID',
                                decimalDigits: 0,
                                symbol: 'Rp. ',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IgnorePointer(
                          ignoring: ignorePointer,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(Warna.ungu),
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
                                  ignorePointerTimer = Timer(const Duration(seconds: 3), () {
                                    setState(() {
                                      ignorePointer = false;
                                    });
                                  });
                                });
                                EasyLoading.show(status: "Loading...");
                                insertData();
                              }
                            },
                            child: const Text(
                              "Submit",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        TextButton(
                          style: ButtonStyle(
                              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5), side: BorderSide(color: Warna.ungu)))),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            "Cancel",
                            style: TextStyle(
                              color: Warna.ungu,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
