import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/utils.dart';
import 'package:UB/adminDashboard/dashboard.dart';
import 'package:UB/billing/presentation/allReading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '../adminDashboard/graph.dart';
import '../billing/billing_watcher/billing_watcher_bloc.dart';
import '../billing/domain/billingDetails.dart';
import '../injection.dart';
import 'package:intl/intl.dart';

import '../loginSignup/welcomePage.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({Key? key}) : super(key: key);

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  @override
  int _index = 0;
  String eDay = '0';
  String eNight = '0';
  String gas = '0';
  String standingCharge = '0';
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic> price = {};
  User? firebaseUser = FirebaseAuth.instance.currentUser;
  int count = 0;
  int countWeek = 0;
  int countMonth = 0;

  double averageElectricityDay = 0;
  double averageElectricityNight = 0;
  double averageElectricity = 0;

  double averageElectricityDayWeek = 0;
  double averageElectricityNightWeek = 0;
  double averageElectricityWeek = 0;

  double averageElectricityDayMonth = 0;
  double averageElectricityNightMonth = 0;
  double averageElectricityMonth = 0;

  double averageGas = 0;
  double average = 0;

  double averageGasWeek = 0;
  double averageWeek = 0;

  double averageGasMonth = 0;
  double averageMonth = 0;

  double displayElectricAverage = 0;
  double displayGasAverage = 0;
  bool initial = true;

  var weekTime = DateTime.fromMillisecondsSinceEpoch(
      DateTime.now().subtract(Duration(days: 7)).millisecondsSinceEpoch);
  var monthTime = DateTime.fromMillisecondsSinceEpoch(
      DateTime.now().subtract(Duration(days: 30)).millisecondsSinceEpoch);
  @override
  void initState() {
    getData();
    super.initState();
  }

  getData() async {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('setPrice')
        .doc('price')
        .get();
    price = documentSnapshot.get('setPrice');
    print('printing voucher----------${price.length}');
    price.forEach((key, value) {
      setState(() {
        if (key == 'ElectricityDay') {
          eDay = value.toString();
        }
        if (key == 'ElectricityNight') {
          eNight = value.toString();
        }
        if (key == 'StandingCharge') {
          standingCharge = value.toString();
        }
        if (key == 'gas') {
          gas = value.toString();
        }
      });
    });
  }

  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text(
            'admin home page',
            style: TextStyle(color: Colors.black),
          ),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.all(6),
              child: GestureDetector(
                onTap: () async {
                  final prefs = await SharedPreferences.getInstance();
                  final success = await prefs.remove('lastLogin');
                  await FirebaseAuth.instance.signOut().then((value) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const WelcomePage()));
                  });
                },
                child: const Icon(
                  Icons.logout,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
        body: MultiBlocProvider(
            providers: [
              BlocProvider<BillingWatcherBloc>(
                create: (context) => getIt<BillingWatcherBloc>()
                  ..add(BillingWatcherEvent.watchAllStarted()),
              ),
            ],
            child: BlocBuilder<BillingWatcherBloc, BillingWatcherState>(
              builder: (context, state) {
                return state.map(
                  initial: (_) {
                    return Container(
                      width: 1.sw,
                      height: 1.sw,
                      color: Colors.white,
                      child: CircularProgressIndicator(
                        color: Colors.blue,
                      ),
                    );
                  },
                  loadInProgress: (_) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  loadSuccess: (state) {
                    if (initial) {
                      meterReadings(state.billingList);
                      if (averageElectricityDay != 0) {
                        averageElectricity =
                            (averageElectricityDay + averageElectricityNight) /
                                (count * 2);
                        average = averageGas / count;
                      }
                      averageElectricityWeek = (averageElectricityDayWeek +
                              averageElectricityNightWeek) /
                          (countWeek * 2);
                      averageWeek = averageGasWeek / countWeek;

                      averageElectricityMonth = (averageElectricityDayMonth +
                              averageElectricityNightMonth) /
                          (countMonth * 2);
                      averageMonth = averageGasMonth / countMonth;

                      displayElectricAverage = averageElectricity;
                      displayGasAverage = average;
                    }

                    return SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          const Padding(
                            padding: EdgeInsets.all(10),
                            child: Text(
                              'set Electricity and gas price(in kwh)',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              GestureDetector(
                                child: Container(
                                  width: .22.sw,
                                  height: .22.sw,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.2),
                                          spreadRadius: 3,
                                          blurRadius: 5,
                                          offset: Offset(0,
                                              4), // changes position of shadow
                                        ),
                                      ]),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'Day',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      Text(
                                        eDay,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 20),
                                      ),
                                      Text('\$'),
                                    ],
                                  ),
                                ),
                                onTap: () {
                                  showAlertDialog(context);
                                },
                              ),
                              GestureDetector(
                                child: Container(
                                  width: .22.sw,
                                  height: .22.sw,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.2),
                                          spreadRadius: 3,
                                          blurRadius: 5,
                                          offset: Offset(0,
                                              4), // changes position of shadow
                                        ),
                                      ]),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'Night',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      Text(
                                        eNight,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 20),
                                      ),
                                      Text('\$'),
                                    ],
                                  ),
                                ),
                                onTap: () {
                                  showAlertDialog(context);
                                },
                              ),
                              GestureDetector(
                                child: Container(
                                  width: .22.sw,
                                  height: .22.sw,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.2),
                                          spreadRadius: 3,
                                          blurRadius: 5,
                                          offset: Offset(0,
                                              4), // changes position of shadow
                                        ),
                                      ]),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'gas',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      Text(
                                        gas,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 20),
                                      ),
                                      Text('\$'),
                                    ],
                                  ),
                                ),
                                onTap: () {
                                  showAlertDialog(context);
                                },
                              ),
                              GestureDetector(
                                child: Container(
                                  width: .22.sw,
                                  height: .22.sw,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.2),
                                          spreadRadius: 3,
                                          blurRadius: 5,
                                          offset: Offset(0,
                                              4), // changes position of shadow
                                        ),
                                      ]),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'Standing\ncharge',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      Text(
                                        standingCharge,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 20),
                                      ),
                                      Text('\$'),
                                    ],
                                  ),
                                ),
                                onTap: () {
                                  showAlertDialog(context);
                                },
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Center(
                            child: GestureDetector(
                              child: Container(
                                width: .6.sw,
                                height: .1.sw,
                                decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.2),
                                        spreadRadius: 3,
                                        blurRadius: 5,
                                        offset: Offset(
                                            0, 4), // changes position of shadow
                                      ),
                                    ]),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: const [
                                    Text(
                                      'All meter readings',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const AllReadings()));
                              },
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(10),
                            child: Text(
                              'Average meter readings:',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(5),
                            child: Center(
                              child: ToggleSwitch(
                                minHeight: 0.09.sw,
                                minWidth: 0.27.sw,
                                initialLabelIndex: _index,
                                totalSwitches: 3,
                                activeBgColor: [Colors.black],
                                inactiveBgColor: Colors.white,
                                borderColor: [Colors.black],
                                dividerColor: Colors.black,
                                borderWidth: 1,
                                cornerRadius: 10,

                                // customTextStyles: const [
                                //   TextStyle(
                                //       color: Colors.white
                                //   ),
                                //   TextStyle(
                                //       color: Colors.white
                                //   ),
                                //   TextStyle(
                                //       color: Colors.white
                                //   ),
                                //
                                // ],
                                labels: ['Today', 'Week', 'Month'],
                                onToggle: (index) {
                                  setState(() {
                                    if (index == 0) {
                                      _index = 0;
                                      displayElectricAverage =
                                          averageElectricity;
                                      displayGasAverage = average;
                                    }
                                    if (index == 1) {
                                      _index = 1;

                                      displayElectricAverage =
                                          averageElectricityWeek;
                                      displayGasAverage = averageWeek;
                                    }
                                    if (index == 2) {
                                      _index = 2;

                                      displayElectricAverage =
                                          averageElectricityMonth;
                                      displayGasAverage = averageMonth;
                                    }
                                  });
                                },
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Container(
                                width: .4.sw,
                                height: .3.sw,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.2),
                                        spreadRadius: 3,
                                        blurRadius: 5,
                                        offset: Offset(
                                            0, 4), // changes position of shadow
                                      ),
                                    ]),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Electricity',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    Text(
                                      displayElectricAverage.toStringAsFixed(2),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 24),
                                    ),
                                    const Text(
                                      'kwh',
                                      style: TextStyle(
                                          fontSize: 15, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: .4.sw,
                                height: .3.sw,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.2),
                                        spreadRadius: 3,
                                        blurRadius: 5,
                                        offset: Offset(
                                            0, 4), // changes position of shadow
                                      ),
                                    ]),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Gas',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    Text(
                                      displayGasAverage.toStringAsFixed(2),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 24),
                                    ),
                                    const Text(
                                      'kwh',
                                      style: TextStyle(
                                          fontSize: 15, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          const Padding(
                            padding: EdgeInsets.all(10),
                            child: Text(
                              'Graph :',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                        color: Color(0xff845bef),
                                        shape: BoxShape.circle),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text("Electricty (kwh)")
                                ],
                              ),
                              Row(
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                        color: Color(0xff13d38e),
                                        shape: BoxShape.circle),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text("Gas (kwh)")
                                ],
                              ),
                            ],
                          ),
                          BarGraph(
                              averageElectricity,
                              average,
                              averageElectricityWeek,
                              averageWeek,
                              averageElectricityMonth,
                              averageMonth),
                          SizedBox(
                            height: 20,
                          )
                        ],
                      ),
                    );
                  },
                  loadFailure: (state) {
                    return Container(
                      width: 1.sw,
                      height: 1.sw,
                      color: Colors.white,
                      child: const Text(
                          'something went wrong please contact the admin'),
                    );
                  },
                );
              },
            )),
      ),
    );
  }

  showAlertDialog(BuildContext context) {
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
      },
    );
    Widget continueButton = TextButton(
      child: Text("submit"),
      onPressed: () async {
        if (_formKey.currentState!.validate()) {
          setState(() {});
          await FirebaseFirestore.instance
              .collection('setPrice')
              .doc('price')
              .set({
            'setPrice': {
              'ElectricityDay': double.parse(eDay),
              'ElectricityNight': double.parse(eNight),
              'StandingCharge': double.parse(standingCharge),
              'gas': double.parse(gas),
            }
          }, SetOptions(merge: true));
          Navigator.of(context, rootNavigator: true).pop();
        }
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(32.0))),
      content: Container(
        width: 0.9.sw,
        height: 1.sw,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Electricity meter price - Day(in \$)',
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                TextFormField(
                  initialValue: eDay,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  style: TextStyle(
                      color: Theme.of(context).textTheme.bodyText1!.color,
                      fontWeight: FontWeight.w500,
                      fontFamily:
                          Theme.of(context).textTheme.subtitle1!.fontFamily,
                      fontStyle: FontStyle.normal,
                      fontSize: 15),
                  decoration: InputDecoration(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.red, width: 0.0),
                    ),
                    suffixIconConstraints:
                        const BoxConstraints(minWidth: 23, maxHeight: 20),
                    errorStyle: TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        fontFamily:
                            Theme.of(context).textTheme.subtitle1!.fontFamily,
                        fontWeight: FontWeight.normal),
                    hintText: 'Enter price',
                    hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(
                        color: Colors.grey,
                        width: 0.0,
                      ),
                    ),
                    // border: const OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    eDay = value;
                  },
                  validator: (String? value) {
                    const pattern = r"^[0.0-9.9]+$";
                    RegExp regExp = new RegExp(pattern);
                    if (value!.isEmpty) {
                      return 'Enter price';
                    } else if (!regExp.hasMatch(value)) {
                      return 'Please enter valid price';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 0.08.sw),
                Text(
                  'Electricity meter price - Night(in \$)',
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                TextFormField(
                  initialValue: eNight,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  style: TextStyle(
                      color: Theme.of(context).textTheme.bodyText1!.color,
                      fontWeight: FontWeight.w500,
                      fontFamily:
                          Theme.of(context).textTheme.subtitle1!.fontFamily,
                      fontStyle: FontStyle.normal,
                      fontSize: 15),
                  decoration: InputDecoration(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.red, width: 0.0),
                    ),
                    suffixIconConstraints:
                        const BoxConstraints(minWidth: 23, maxHeight: 20),
                    errorStyle: TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        fontFamily:
                            Theme.of(context).textTheme.subtitle1!.fontFamily,
                        fontWeight: FontWeight.normal),
                    hintText: 'Enter price',
                    hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(
                        color: Colors.grey,
                        width: 0.0,
                      ),
                    ),
                    // border: const OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    eNight = value;
                  },
                  validator: (String? value) {
                    const pattern = r"^[0.0-9.9]+$";
                    RegExp regExp = new RegExp(pattern);
                    if (value!.isEmpty) {
                      return 'Enter price';
                    } else if (!regExp.hasMatch(value)) {
                      return 'Please enter valid price';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 0.08.sw),
                Text(
                  'Gas price(in \$)',
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                TextFormField(
                  initialValue: gas,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  style: TextStyle(
                      color: Theme.of(context).textTheme.bodyText1!.color,
                      fontWeight: FontWeight.w500,
                      fontFamily:
                          Theme.of(context).textTheme.subtitle1!.fontFamily,
                      fontStyle: FontStyle.normal,
                      fontSize: 15),
                  decoration: InputDecoration(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.red, width: 0.0),
                    ),
                    suffixIconConstraints:
                        const BoxConstraints(minWidth: 23, maxHeight: 20),
                    errorStyle: TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        fontFamily:
                            Theme.of(context).textTheme.subtitle1!.fontFamily,
                        fontWeight: FontWeight.normal),
                    hintText: 'Enter price',
                    hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(
                        color: Colors.grey,
                        width: 0.0,
                      ),
                    ),
                    // border: const OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    gas = value;
                  },
                  validator: (String? value) {
                    const pattern = r"^[0.0-9.9]+$";
                    RegExp regExp = new RegExp(pattern);
                    if (value!.isEmpty) {
                      return 'Enter price';
                    } else if (!regExp.hasMatch(value)) {
                      return 'Please enter valid price';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 0.08.sw),
                Text(
                  'standing charge price(in \$)',
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                TextFormField(
                  initialValue: standingCharge,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  style: TextStyle(
                      color: Theme.of(context).textTheme.bodyText1!.color,
                      fontWeight: FontWeight.w500,
                      fontFamily:
                          Theme.of(context).textTheme.subtitle1!.fontFamily,
                      fontStyle: FontStyle.normal,
                      fontSize: 15),
                  decoration: InputDecoration(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.red, width: 0.0),
                    ),
                    suffixIconConstraints:
                        const BoxConstraints(minWidth: 23, maxHeight: 20),
                    errorStyle: TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        fontFamily:
                            Theme.of(context).textTheme.subtitle1!.fontFamily,
                        fontWeight: FontWeight.normal),
                    hintText: 'Enter meter reading',
                    hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(
                        color: Colors.grey,
                        width: 0.0,
                      ),
                    ),
                    // border: const OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    standingCharge = value;
                  },
                  validator: (String? value) {
                    const pattern = r"^[0.0-9.9]+$";
                    RegExp regExp = new RegExp(pattern);
                    if (value!.isEmpty) {
                      return 'Enter price';
                    } else if (!regExp.hasMatch(value)) {
                      return 'Please enter valid price';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  meterReadings(List<BillingDetailsList> billingList) {
    billingList.forEach((element) {
      var date = DateTime.fromMillisecondsSinceEpoch(
          element.billingTime!.millisecondsSinceEpoch);
      if (DateFormat('dd/MM/yyyy').format(DateTime.fromMillisecondsSinceEpoch(
              element.billingTime!.millisecondsSinceEpoch)) ==
          DateFormat('dd/MM/yyyy').format(DateTime.fromMillisecondsSinceEpoch(
              DateTime.now().millisecondsSinceEpoch))) {
        count = count + 1;
        averageElectricityDay = averageElectricityDay +
            double.parse(element.meterReadings!.previousMeterReadingsDay!);
        averageElectricityNight = averageElectricityNight +
            double.parse(element.meterReadings!.previousMeterReadingsNight!);
        averageGas = averageGas +
            double.parse(element.meterReadings!.previousMeterReadingsGas!);
      }
      if (date.isAfter(weekTime) && date.isBefore(DateTime.now())) {
        countWeek = countWeek + 1;
        averageElectricityDayWeek = averageElectricityDayWeek +
            double.parse(element.meterReadings!.previousMeterReadingsDay!);
        averageElectricityNightWeek = averageElectricityNightWeek +
            double.parse(element.meterReadings!.previousMeterReadingsNight!);
        averageGasWeek = averageGasWeek +
            double.parse(element.meterReadings!.previousMeterReadingsGas!);
      }

      if (date.isAfter(monthTime) && date.isBefore(DateTime.now())) {
        countMonth = countMonth + 1;
        averageElectricityDayMonth = averageElectricityDayMonth +
            double.parse(element.meterReadings!.previousMeterReadingsDay!);
        averageElectricityNightMonth = averageElectricityNightMonth +
            double.parse(element.meterReadings!.previousMeterReadingsNight!);
        averageGasMonth = averageGasMonth +
            double.parse(element.meterReadings!.previousMeterReadingsGas!);
      }
      initial = false;
    });
  }
}
