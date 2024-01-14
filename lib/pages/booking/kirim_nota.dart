import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class Nota {
  static kirimNota(Map<dynamic, dynamic> data, String idUser, String idBooking,
      BuildContext context) async {
    try {
      var id_nota = FirebaseDatabase.instance.ref().push().key;
      EasyLoading.show(status: 'loading...');
      await FirebaseDatabase.instance
          .ref()
          .child("booking")
          .child(idBooking)
          .update({
        "id_nota": id_nota,
        "status_booking": "Menunggu Pengambilan",
      }).then((value) {
        FirebaseDatabase.instance
            .ref()
            .child("nota")
            .child(idUser)
            .child(id_nota!)
            .set({
          "id_booking": idBooking.toString(),
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
      });
    } on Exception catch (e) {
      EasyLoading.showError('Ada Sesuatu Kesalahan : $e',
          dismissOnTap: true, duration: const Duration(seconds: 5));
    }
  }
}
