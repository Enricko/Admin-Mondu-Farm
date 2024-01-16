import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class Nota {
  static kirimNota(Map<dynamic, dynamic> data, String idUser, String idBooking,
      String idTernak, BuildContext context) async {
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
          "id_user": idUser.toString(),
          "id_ternak": idTernak.toString(),
          "kategori": data['kategori'].toString(),
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

  static accNota(Map<dynamic, dynamic> data, BuildContext context) async {
    try {
      EasyLoading.show(status: 'loading...');
      await FirebaseDatabase.instance
          .ref()
          .child("ternak")
          .child(data['kategori'].toString())
          .child(data['id_ternak'].toString())
          .remove()
          .then((value) {
        FirebaseDatabase.instance
            .ref()
            .child("booking")
            .child(data['id_booking'].toString())
            .remove()
            .then((value) {
          FirebaseDatabase.instance
              .ref()
              .child("nota")
              .child(data['id_user'].toString())
              .child(data['id_nota'].toString())
              .remove()
              .then((value) {
            FirebaseDatabase.instance
                .ref()
                .child("pesan")
                .child(data['id_user'].toString())
                .child(data['id_ternak'].toString())
                .remove().whenComplete(() {
              EasyLoading.showSuccess('Ternak Terjual',
                  dismissOnTap: true, duration: const Duration(seconds: 5));
              // Navigator.pop(context);
              return;
            });
          });
        });
      });
    } on Exception catch (e) {
      EasyLoading.showError('Ada Sesuatu Kesalahan : $e',
          dismissOnTap: true, duration: const Duration(seconds: 5));
    }
  }
}
