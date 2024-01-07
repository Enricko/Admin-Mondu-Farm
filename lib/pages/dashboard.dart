import 'package:admin_mondu_farm/pages/main_page.dart';
import 'package:admin_mondu_farm/utils/color.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "Dashboard",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        SizedBox(
          height: 15,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Container(
            //   width: 50,
            //   height: 50,
            //   alignment: Alignment.center,
            //   decoration: BoxDecoration(
            //     color: Warna.ungu,
            //     borderRadius: BorderRadius.circular(10),
            //   ),
            //   child: Icon(Icons.message),
            // ),
            // SizedBox(
            //   width: 10,
            // ),
            Tooltip(
              message: "Booking",
              child: Container(
                width: 50,
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Warna.ungu,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.library_books),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 25,
        ),
        Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 15),
            child: ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) {
                return Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(vertical: 1),
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  decoration: BoxDecoration(
                    color: Warna.biruUngu,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(color: Warna.ungu, borderRadius: BorderRadius.circular(50)),
                            child: Text("$index"),
                          ),
                          SizedBox(
                            width: 25,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Nama",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                ),
                              ),
                              Text("No Telpon"),
                            ],
                          )
                        ],
                      ),
                      Row(
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => MainPage(
                                    uid: index.toString(),
                                    route: "chat",
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              width: 50,
                              height: 50,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Warna.ungu,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(Icons.message),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
