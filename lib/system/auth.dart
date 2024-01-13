import 'package:admin_mondu_farm/pages/main_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Auth {
  // Login Logic Functions
  static login(Map<dynamic, dynamic> data, BuildContext context) async {
    try {
      // UI Loading
      EasyLoading.show(status: 'loading...');
      // Login menggunakan function signInWithEmailAndPassword() yang telah di sediakan oleh firebase
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: data['email'], password: data['password'])
          .then((user) async {
        // Mengambil semua data user yang ada di dalam database lalu di filter
        FirebaseDatabase.instance.ref().child("users").child(user.user!.uid).onValue.listen((event) async {
          // Menyimpan data pada device menggunakan SharedPreferences
          SharedPreferences pref = await SharedPreferences.getInstance();
          if (event.snapshot.exists) {
            var getUser = event.snapshot.value as Map;
            // Menyimpan beberapa data yg penting ke device agar tidak selalu login
            pref.setString("id_user", user.user!.uid.toString());
            pref.setString("nama", getUser['nama'].toString());
            pref.setString("email", getUser['email'].toString());
            pref.setString("level", getUser['level'].toString());
            pref.setInt("no_telepon", int.parse(getUser['no_telepon'].toString()));
            EasyLoading.showSuccess('Welcome Back', dismissOnTap: true);
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => MainPage()));
            return;
          } else {
            FirebaseDatabase.instance.ref().child("users").child(user.user!.uid).remove();
            FirebaseAuth.instance.currentUser!.delete();
            EasyLoading.showError('Maaf akun ada tidak ada', dismissOnTap: true);
            return; 
          }
        });
      }).onError((error, stackTrace) {
        EasyLoading.showError('Email/Password anda salah!', dismissOnTap: true, duration: const Duration(seconds: 5));
        return null;
      }).timeout(Duration(seconds: 10), onTimeout: () {
        EasyLoading.showError('Maaf tunggu lagi beberapa saat!', dismissOnTap: true);
      });

      // Mengarah ke halaman dashboard jika berhasil
    } on Exception catch (e) {
      // Menampilkan error yang terjadi pada block code di atas
      EasyLoading.showError('Email/Password anda salah!', dismissOnTap: true, duration: const Duration(seconds: 5));
    }
  }

  // SignUp Logic Functions
  static signUp(Map<dynamic, dynamic> data, BuildContext context) async {
    // Menjalankan block code di dalam agar kita mengetahui jika code tersebut errored
    try {
      // UI Loading
      EasyLoading.show(status: 'loading...');

      // Initialize Firebase Authentication
      FirebaseApp app = await Firebase.initializeApp(name: 'AuthUser', options: Firebase.app().options);

      // Insert User to FirebaseAuth
      FirebaseAuth.instanceFor(app: app)
          .createUserWithEmailAndPassword(email: data['email'], password: data['password'])
          .then((value) {
        // Setting Nama di firebase Authentication
        value.user!.updateDisplayName(data['nama']);
        // Insert User to database
        FirebaseDatabase.instance.ref().child("users").child(value.user!.uid).set({
          "nama": data['nama'],
          "email": data['email'],
          "level": "admin",
          "no_telepon": data['no_telepon'],
        }).whenComplete(() {
          // Jika logic telah selesai berjalan, kode yang di bawah ini bakal jalan
          EasyLoading.showSuccess('Tambah Akun Berhasil', dismissOnTap: true, duration: const Duration(seconds: 5));
          // Mengarah ke Login Page jika Sign Up Berhasil
          Navigator.pop(context);
          // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
        }).onError((error, stackTrace) {
          // Jika logic mengalami error, kode yang di bawah ini bakal jalan
          EasyLoading.showError('$error', dismissOnTap: true, duration: const Duration(seconds: 5));
        }).timeout(Duration(seconds: 10), onTimeout: () {
          EasyLoading.showError('Maaf tunggu lagi beberapa saat!', dismissOnTap: true);
        });
      }).onError((error, stackTrace) {
        // Jika logic mengalami error, kode yang di bawah ini bakal jalan
        EasyLoading.showError('$error', dismissOnTap: true, duration: const Duration(seconds: 5));
      }).catchError((error) {
        // Jika logic mengalami error, kode yang di bawah ini bakal jalan
        EasyLoading.showError('$error', dismissOnTap: true, duration: const Duration(seconds: 5));
      });
    } on Exception catch (e) {
      // Menampilkan error yang terjadi pada block code di atas
      EasyLoading.showError('Ada Sesuatu Kesalahan : $e', dismissOnTap: true, duration: const Duration(seconds: 5));
    }
  }
}
