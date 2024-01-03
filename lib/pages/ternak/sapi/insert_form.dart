import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:admin_mondu_farm/utils/color.dart';
import 'package:admin_mondu_farm/utils/custom_extension.dart';
import 'package:admin_mondu_farm/utils/text_field.dart';
import 'package:firebase_database/firebase_database.dart';
import "package:firebase_storage/firebase_storage.dart";
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';

class AddTernakForm extends StatefulWidget {
  const AddTernakForm({
    super.key,
    required this.width,
  });

  final double width;

  @override
  State<AddTernakForm> createState() => _AddTernakFormState();
}

class _AddTernakFormState extends State<AddTernakForm> {
  DatabaseReference db = FirebaseDatabase.instance.ref().child('ternak').child("sapi");
  TextEditingController usiaController = TextEditingController();
  TextEditingController tinggiController = TextEditingController();
  TextEditingController beratController = TextEditingController();
  TextEditingController hargaController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool ignorePointer = false;
  Timer? ignorePointerTimer;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();

    if (ignorePointerTimer != null) {
      ignorePointerTimer!.cancel();
    }
  }

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
      var metadata = SettableMetadata(
        contentType: "image/jpeg",
      );
      var imagefile = FirebaseStorage.instance
          .ref()
          .child("ternak")
          .child("sapi")
          .child("${generateRandomString(10)}-${DateTime.now()}.png");

      UploadTask task = imagefile.putData(webImage);
      if (!kIsWeb) {
        UploadTask task = imagefile.putFile(file!);
      }
      TaskSnapshot snapshot = await task;
      var url = await snapshot.ref.getDownloadURL();
      if (url != null) {
        Map<String, dynamic> val = {
          'usia': usiaController.text,
          "deskripsi": tinggiController.text,
          "harga": beratController.text,
          "kategori": hargaController.text,
          'image': url,
        };

        FirebaseDatabase.instance.ref().child("ternak").child("sapi").push().set(val).whenComplete(() {
          EasyLoading.showSuccess('Sapi telah di tambahkan', dismissOnTap: true, duration: Duration(seconds: 3));
          Navigator.pop(context);
          return;
        });
      }
    } on Exception catch (e) {
      EasyLoading.showError('Error : ${e}', dismissOnTap: true, duration: Duration(seconds: 3));
      print(e);
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
                  "Tambah Ternak Sapi",
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
                              if (_formKey.currentState!.validate() && (webImage != null && file != null)) {
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
