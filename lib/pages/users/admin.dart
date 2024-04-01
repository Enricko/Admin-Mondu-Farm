import 'dart:async';
import 'dart:math';

import 'package:admin_mondu_farm/pages/login.dart';
import 'package:admin_mondu_farm/system/auth.dart';
import 'package:admin_mondu_farm/utils/alerts.dart';
import 'package:admin_mondu_farm/utils/color.dart';
import 'package:admin_mondu_farm/utils/custom_extension.dart';
import 'package:admin_mondu_farm/utils/text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pagination_flutter/pagination.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class AdminTable extends StatefulWidget {
  const AdminTable({super.key});

  @override
  State<AdminTable> createState() => _AdminTableState();
}

class _AdminTableState extends State<AdminTable> {
  final _formKey = GlobalKey<FormState>();
  DatabaseReference db = FirebaseDatabase.instance.ref().child('users');
  int page = 1;
  int perpage = 10;

  incrementPage(int pageIndex) {
    setState(() {
      page = pageIndex;
    });
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
            "Table Admin",
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
                  child: TambahUser(),
                );
              },
            );
          },
          child: Text("Tambah Admin"),
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
                  Map<dynamic, dynamic>.from((snapshot.data!).snapshot.value as Map<dynamic, dynamic>);
              data.removeWhere((key, value) => value['level'] == null || value['level'] == "user");
              return Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
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
                                  DataColumn(label: Text("Nama")),
                                  DataColumn(label: Text("Email")),
                                  DataColumn(label: Text("No Telphone")),
                                  DataColumn(label: Text("Action")),
                                ],
                                rows: data.entries.skip((page - 1) * perpage).take(perpage).map((val) {
                                  var numberedTable = data.entries.toList().indexWhere(
                                          (element) => element.value == val.value && element.key == val.key) +
                                      1;
                                  return DataRow(cells: [
                                    DataCell(Text(numberedTable.toString())),
                                    DataCell(Text(val.value['nama'])),
                                    DataCell(Text(val.value['email']!)),
                                    DataCell(Text(val.value['no_telepon']!.toString())),
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
                                                    child: EditUserForm(
                                                      width: width,
                                                      formKey: _formKey,
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
                                          message: "Hapus",
                                          child: IconButton(
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                            onPressed: () {
                                              Alerts.showAlertYesNo(
                                                title: "Apakah anda yakin?",
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
                                DataColumn(label: Text("Nama")),
                                DataColumn(label: Text("Email")),
                                DataColumn(label: Text("No Telphone")),
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

class TambahUser extends StatefulWidget {
  const TambahUser({super.key});

  @override
  State<TambahUser> createState() => _TambahUserState();
}

class _TambahUserState extends State<TambahUser> {
  TextEditingController namaController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController noTelponController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool ignorePointer = false;
  Timer? ignorePointerTimer;

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

  @override
  void initState() {
    super.initState();
    cekUser();
  }

  @override
  void dispose() {
    super.dispose();

    if (ignorePointerTimer != null) {
      ignorePointerTimer!.cancel();
    }
  }

  void signUp(BuildContext context) {
    var nama = namaController.text;
    var email = emailController.text;
    var noTelpon = noTelponController.text;
    var password = passwordController.text;

    var data = {
      "nama": nama,
      "email": email,
      "password": password,
      "no_telepon": noTelpon,
    };
    Auth.signUp(data, context);
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Container(
      width: width <= 540 ? width / 1.3 : width / 1.6,
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
                  "Tambah User",
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
                          CustomTextField(
                            controller: namaController,
                            hint: "Nama",
                            type: TextInputType.text,
                            validator: (value) {
                              if (value == null || value == "") {
                                return "Mohon form-nya diisi.";
                              }
                            },
                          ),
                          CustomTextField(
                            controller: noTelponController,
                            hint: "No Telpon",
                            type: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validator: (value) {
                              if (value == null || value == "") {
                                return "Mohon form-nya diisi.";
                              }
                            },
                          ),
                          CustomTextField(
                            controller: emailController,
                            hint: "Email",
                            type: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value == "") {
                                return "Mohon form-nya diisi.";
                              }
                            },
                          ),
                          CustomTextField(
                            controller: passwordController,
                            hint: "Password",
                            type: TextInputType.visiblePassword,
                            validator: (value) {
                              if (value == null || value == "") {
                                return "Mohon form-nya diisi.";
                              }
                            },
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
                                signUp(context);
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

class EditUserForm extends StatefulWidget {
  const EditUserForm({
    super.key,
    required this.width,
    required GlobalKey<FormState> formKey,
    required this.id,
    required this.data,
  }) : _formKey = formKey;

  final String id;
  final Map data;
  final double width;
  final GlobalKey<FormState> _formKey;

  @override
  State<EditUserForm> createState() => _EditUserFormState();
}

class _EditUserFormState extends State<EditUserForm> {
  TextEditingController namaController = TextEditingController();
  TextEditingController noTelponController = TextEditingController();
  bool ignorePointer = false;
  Timer? ignorePointerTimer;

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

  @override
  void initState() {
    super.initState();
    cekUser();
    namaController.text = widget.data['nama'];
    noTelponController.text = widget.data['no_telepon'].toString();
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
                  "Edit User",
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
                      key: widget._formKey,
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 5,
                          ),
                          CustomTextField(
                            controller: namaController,
                            hint: "Nama",
                            type: TextInputType.text,
                            validator: (value) {
                              if (value == null || value == "") {
                                return "Mohon form-nya diisi.";
                              }
                            },
                          ),
                          CustomTextField(
                            controller: noTelponController,
                            hint: "No Telpon",
                            type: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validator: (value) {
                              if (value == null || value == "") {
                                return "Mohon form-nya diisi.";
                              }
                            },
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
                              if (widget._formKey.currentState!.validate()) {
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
                                print(noTelponController.text);
                                FirebaseDatabase.instance.ref().child("users").child(widget.id).update({
                                  "nama": namaController.text,
                                  "no_telepon": noTelponController.text,
                                }).whenComplete(() {
                                  EasyLoading.showSuccess("Data User Telah di Ubah.",
                                      dismissOnTap: true, duration: Duration(seconds: 3));
                                  Navigator.pop(context);
                                }).onError((error, stackTrace) {
                                  EasyLoading.showSuccess("Error : ${error}",
                                      dismissOnTap: true, duration: Duration(seconds: 3));
                                });
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
