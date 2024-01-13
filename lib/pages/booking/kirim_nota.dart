import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class Nota {
  static kirimNota(
      Map<dynamic, dynamic> data, String idUser, BuildContext context) async {
    try {
      EasyLoading.show(status: 'loading...');
      await FirebaseDatabase.instance
          .ref()
          .child("nota")
          .child(idUser)
          .push()
          .set({
        "nama": data['nama'].toString(),
        "no_telepon": data['no_telepon'].toString(),
        "urlGambar": data['urlGambar'].toString(),
        "tanggal_booking": data['tanggal_booking'].toString(),
        "umur": data["umur"].toString(),
        "berat": data["berat"].toString(),
        "tinggi": data["tinggi"].toString(),
        "harga": data["harga"].toString(),
      }).whenComplete(() {
        EasyLoading.showSuccess('Nota Terkirim',
            dismissOnTap: true, duration: const Duration(seconds: 5));
        Navigator.pop(context);
        return;
      }).onError((error, stackTrace) {
        EasyLoading.showError("Ada Sesuatu Kesalahan: $error",
            dismissOnTap: true, duration: const Duration(seconds: 5));
      });
    } on Exception catch (e) {
      EasyLoading.showError('Ada Sesuatu Kesalahan : $e',
          dismissOnTap: true, duration: const Duration(seconds: 5));
    }
  }
}
