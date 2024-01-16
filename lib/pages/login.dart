import 'package:admin_mondu_farm/pages/main_page.dart';
import 'package:admin_mondu_farm/system/auth.dart';
import 'package:admin_mondu_farm/utils/color.dart';
import 'package:flutter/material.dart';
import "package:firebase_auth/firebase_auth.dart";

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool invisible = true;

  void cekUser() async {
    await FirebaseAuth.instance.currentUser;
    // Logic cek Data User apakah sudah pernah login
    if (FirebaseAuth.instance.currentUser != null) {
      FirebaseAuth.instance.currentUser;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => MainPage()));
      });
    }
  }

  // Logic form input Login
  void login(BuildContext context) {
    // Mengubah Controller menjadi String/huruf
    var email = emailController.text;
    var password = passwordController.text;

    // Menjadikan Map agar mudah di pindah ke function lain
    var data = {
      "email": email,
      "password": password,
    };
    // Menjalankan Logic Class Function Auth Login
    Auth.login(data, context);

    // //Testing
    // var data = {
    //   "nama": "enricko",
    //   "email": "enricko.putra028@gmail.com",
    //   // "level":"admin",
    //   "password": "123qweasd",
    //   "no_telepon": "085158426044",
    // };
    // Auth.signUp(data, context);

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
    return Scaffold(
      backgroundColor: Warna.latar,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 75,
                height: 75,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: Warna.ungu, borderRadius: BorderRadius.circular(100)),
                child: Image.network(
                  "assets/gambar/password_user.png",
                  width: 75,
                ),
              ),
              SizedBox(
                height: 25,
              ),
              Container(
                width: width >= 600 ? width * 0.5 : width * 0.75,
                padding: EdgeInsets.symmetric(horizontal: width * .1, vertical: 50),
                decoration: BoxDecoration(
                  color: Warna.biru,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 5,
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Login",
                      style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(color: Warna.ungu, borderRadius: BorderRadius.circular(50)),
                                child: Image.network(
                                  "assets/gambar/card_hand.png",
                                  width: 50,
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: TextFormField(
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    if (value == null || value == "") {
                                      return "Mohon form-nya diisi.";
                                    }
                                    return null;
                                  },
                                  controller: emailController,
                                  decoration: const InputDecoration(
                                      labelText: "Email",
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(width: 1, color: Colors.blueAccent),
                                      ),
                                      enabledBorder:
                                          OutlineInputBorder(borderSide: BorderSide(width: 1, color: Colors.black38)),
                                      disabledBorder:
                                          OutlineInputBorder(borderSide: BorderSide(width: 1, color: Colors.black38)),
                                      errorBorder:
                                          OutlineInputBorder(borderSide: BorderSide(width: 1, color: Colors.redAccent)),
                                      focusedErrorBorder:
                                          OutlineInputBorder(borderSide: BorderSide(width: 1, color: Colors.redAccent)),
                                      filled: true,
                                      fillColor: Colors.white),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(color: Warna.ungu, borderRadius: BorderRadius.circular(50)),
                                child: Image.network(
                                  "assets/gambar/phone.png",
                                  width: 50,
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: TextFormField(
                                  keyboardType: TextInputType.visiblePassword,
                                  obscureText: invisible,
                                  validator: (value) {
                                    if (value == null || value == "") {
                                      return "Mohon form-nya diisi.";
                                    }
                                    return null;
                                  },
                                  controller: passwordController,
                                  decoration: InputDecoration(
                                    labelText: "Password",
                                    suffixIcon: IconButton(
                                      icon: Icon((invisible == true)
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off),
                                      onPressed: () {
                                        setState(() {
                                          invisible = !invisible;
                                        });
                                      },
                                    ),
                                    // suffixIcon: Icon(Icons.remove_red_eye_rounded),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(width: 1, color: Colors.blueAccent),
                                    ),
                                    enabledBorder:
                                        OutlineInputBorder(borderSide: BorderSide(width: 1, color: Colors.black38)),
                                    disabledBorder:
                                        OutlineInputBorder(borderSide: BorderSide(width: 1, color: Colors.black38)),
                                    errorBorder:
                                        OutlineInputBorder(borderSide: BorderSide(width: 1, color: Colors.redAccent)),
                                    focusedErrorBorder:
                                        OutlineInputBorder(borderSide: BorderSide(width: 1, color: Colors.redAccent)),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 25,
                          ),
                          ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(Warna.biruUngu),
                              foregroundColor: MaterialStateProperty.all(Colors.black),
                            ),
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                // Menjalanan kan logic Login
                                login(context);
                              }
                            },
                            child: Text("Login"),
                          ),
                        ],
                      ),
                    ),
                    // ElevatedButton(onPressed: (){
                    //   login(context);
                    // }, child:Text("signup test"))
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
