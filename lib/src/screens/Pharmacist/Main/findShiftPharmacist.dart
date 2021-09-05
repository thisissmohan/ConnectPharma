import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';
import 'package:pharma_connect/src/screens/Pharmacist/Main/jobDetails.dart';
import 'package:pharma_connect/src/screens/Pharmacist/Main/jobHistoryPharmacist.dart';
import 'package:geocoding/geocoding.dart';

import '../../../../all_used.dart';

class FindShiftForPharmacist extends StatefulWidget {
  FindShiftForPharmacist({Key? key}) : super(key: key);

  @override
  _FindShiftForPharmacistState createState() => _FindShiftForPharmacistState();
}

class _FindShiftForPharmacistState extends State<FindShiftForPharmacist> {
  CollectionReference aggregationRef =
      FirebaseFirestore.instance.collection("aggregation");
  Location pharmacistLocation =
      Location(latitude: 0, longitude: 0, timestamp: DateTime(0));
  Map jobsDataMap = Map();
  Map jobsDataMapTemp = Map();
  Map sortedJobsDataMap = Map();
  StreamSubscription? scheduleJobsDataSub;

  void getAllJobs(DocumentSnapshot jobsData) async {
    setState(() {
      jobsDataMapTemp = jobsData.data() as Map;
    });
  }

  void jobsSortedWithSchedule() {
    jobsDataMapTemp.forEach((key, value) {
      print(value["pharmacyUID"]);
      print("--------------------------------------------");
      if (((value["startDate"] as Timestamp).toDate().isAfter(context
                  .read(pharmacistMainProvider.notifier)
                  .startDate as DateTime) &&
              ((value["startDate"] as Timestamp).toDate().isBefore(context
                  .read(pharmacistMainProvider.notifier)
                  .endDate as DateTime))) ||
          ((value["startDate"] as Timestamp).toDate().day ==
              (context.read(pharmacistMainProvider.notifier).startDate
                      as DateTime)
                  .day)) {
        print(value["pharmacyUID"]);
        print("Key: $key");
        jobsDataMap[key] = value;
        print("YEAS");
      } else {
        print(value["pharmacyUID"]);
        print("Key: $key");
        print("NO");
      }
    });
    print("Jobs Data Map: ${jobsDataMap.keys}");
    setState(() {
      sortedJobsDataMap = Map.fromEntries(jobsDataMap.entries.toList()
        ..sort((e1, e2) =>
            e1.value["startDate"].compareTo(e2.value["startDate"])));
    });
  }

  @override
  void initState() {
    print(context.read(pharmacistMainProvider.notifier).startDate);
    scheduleJobsDataSub?.cancel();
    scheduleJobsDataSub =
        aggregationRef.doc("jobs").snapshots().listen((allJobsData) {
      getAllJobs(allJobsData);
    });

    super.initState();
  }

  @override
  void dispose() {
    scheduleJobsDataSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, watch, child) {
        watch(pharmacistMainProvider);
        return WillPopScope(
          onWillPop: () async {
            context.read(pharmacistMainProvider.notifier).clearDates();
            scheduleJobsDataSub?.cancel();
            return true;
          },
          child: Scaffold(
            appBar: AppBar(
              centerTitle: true,
              iconTheme: IconThemeData(color: Colors.black),
              elevation: 12,
              title: Text(
                "Find Shift",
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 22),
              ),
              backgroundColor: Color(0xFFF6F6F6),
            ),
            body: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                //Start and End Date Fields and Search
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
                  child: Material(
                    elevation: 10,
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      padding: EdgeInsets.fromLTRB(10, 15, 10, 20),
                      child: Column(
                        children: <Widget>[
                          //Start and End Fields Date
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              //Start Date
                              Column(
                                children: <Widget>[
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 0, 0, 5),
                                    child: RichText(
                                      text: TextSpan(
                                        text: "Start Date",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 18.0,
                                            color: Colors.black),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 40,
                                    width: MediaQuery.of(context).size.width *
                                        0.44,
                                    padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
                                    child: DateTimeField(
                                      format: DateFormat("yyyy-MM-dd"),
                                      decoration: InputDecoration(
                                          contentPadding: EdgeInsets.all(12),
                                          isDense: true,
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30)),
                                          labelText: "Select a date"),
                                      onShowPicker:
                                          (context, currentValue) async {
                                        final date = await showDatePicker(
                                            context: context,
                                            firstDate: DateTime.now(),
                                            initialDate:
                                                currentValue ?? DateTime.now(),
                                            lastDate: DateTime(2100));

                                        if (date != null) {
                                          context
                                              .read(pharmacistMainProvider
                                                  .notifier)
                                              .changeStartDate(date);
                                          print(date);
                                          return date;
                                        } else {
                                          context
                                              .read(pharmacistMainProvider
                                                  .notifier)
                                              .changeStartDate(currentValue);
                                          return currentValue;
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),

                              //End Date
                              Column(
                                children: <Widget>[
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 0, 0, 5),
                                    child: RichText(
                                      text: TextSpan(
                                        text: "End Date",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 18.0,
                                            color: Colors.black),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 40,
                                    width: MediaQuery.of(context).size.width *
                                        0.44,
                                    padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
                                    child: DateTimeField(
                                      format: DateFormat("yyyy-MM-dd"),
                                      decoration: InputDecoration(
                                          contentPadding: EdgeInsets.all(12),
                                          isDense: true,
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30)),
                                          labelText: "Select a date"),
                                      onShowPicker:
                                          (context, currentValue) async {
                                        final date = await showDatePicker(
                                            context: context,
                                            firstDate: context
                                                    .read(pharmacistMainProvider
                                                        .notifier)
                                                    .startDate ??
                                                DateTime.now(),
                                            initialDate: context
                                                    .read(pharmacistMainProvider
                                                        .notifier)
                                                    .startDate ??
                                                DateTime.now(),
                                            lastDate: DateTime(2100));

                                        if (date != null) {
                                          context
                                              .read(pharmacistMainProvider
                                                  .notifier)
                                              .changeEndDate(date);
                                          print(date);
                                          return date;
                                        } else {
                                          context
                                              .read(pharmacistMainProvider
                                                  .notifier)
                                              .changeEndDate(currentValue);
                                          return currentValue;
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          //Search Button
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
                            child: SizedBox(
                              width: 324,
                              height: 51,
                              child: ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty
                                        .resolveWith<Color>((states) {
                                      if (states
                                          .contains(MaterialState.disabled)) {
                                        return Colors.grey; // Disabled color
                                      }
                                      return Color(0xFF5DB075); // Regular color
                                    }),
                                    shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(100),
                                    ))),
                                onPressed: (context
                                                .read(pharmacistMainProvider
                                                    .notifier)
                                                .startDate !=
                                            null &&
                                        context
                                                .read(pharmacistMainProvider
                                                    .notifier)
                                                .endDate !=
                                            null)
                                    ? () {
                                        print("Pressed");
                                        //sortedJobsDataMap = {};
                                        //jobsDataMap = {};

                                        jobsSortedWithSchedule();
                                      }
                                    : null,
                                child: RichText(
                                  text: TextSpan(
                                    text: "Search",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                  ),
                ),
                //All Available Shifts
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(5, 20, 5, 0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        SizedBox(height: 10),
                        sortedJobsDataMap.isNotEmpty
                            ? Expanded(
                                child: ListView.builder(
                                  itemCount: sortedJobsDataMap.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    String key =
                                        sortedJobsDataMap.keys.elementAt(index);
                                    //print(sortedJobsDataMap[key]);
                                    return FutureBuilder(
                                      future: getDistance(
                                          sortedJobsDataMap[key],
                                          context
                                              .read(pharmacistMainProvider
                                                  .notifier)
                                              .userDataMap?["address"]),
                                      builder: (BuildContext context,
                                          AsyncSnapshot snapshot) {
                                        if (!snapshot.hasData) {
                                          return Center(
                                              child:
                                                  CircularProgressIndicator());
                                        }
                                        return Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Material(
                                              elevation: 10,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              child: Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.97,
                                                constraints: BoxConstraints(
                                                    minHeight: 90),
                                                child: Center(
                                                  child: ListTile(
                                                    isThreeLine: true,
                                                    title: new Text(
                                                      "${DateFormat("EEE, MMM d yyyy").format((sortedJobsDataMap[key]["startDate"] as Timestamp).toDate())}" +
                                                          " - " +
                                                          "${DateFormat("EE, MMM d yyyy").format((sortedJobsDataMap[key]["endDate"] as Timestamp).toDate())}",
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    subtitle: RichText(
                                                      text: TextSpan(children: [
                                                        TextSpan(
                                                            text:
                                                                "${DateFormat("jm").format((sortedJobsDataMap[key]["startDate"] as Timestamp).toDate())}"
                                                                " - "
                                                                "${DateFormat("jm").format((sortedJobsDataMap[key]["endDate"] as Timestamp).toDate())} ",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize: 15)),
                                                        TextSpan(
                                                            text:
                                                                "(${getHourDiff(TimeOfDay.fromDateTime((sortedJobsDataMap[key]["endDate"] as Timestamp).toDate()), TimeOfDay.fromDateTime((sortedJobsDataMap[key]["startDate"] as Timestamp).toDate()))[0]} hrs"
                                                                "${getHourDiff(TimeOfDay.fromDateTime((sortedJobsDataMap[key]["endDate"] as Timestamp).toDate()), TimeOfDay.fromDateTime((sortedJobsDataMap[key]["startDate"] as Timestamp).toDate()))[1]})\n",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize: 15)),
                                                        TextSpan(
                                                            text:
                                                                "${snapshot.data}",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 15)),
                                                      ]),
                                                    ),
                                                    trailing: Text(
                                                      "${sortedJobsDataMap[key]["hourlyRate"]}/hr\n"
                                                      "Pharmacist",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w600),
                                                    ),
                                                    onTap: () {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder:
                                                                  (context) =>
                                                                      JobDetails(
                                                                        jobDetails:
                                                                            sortedJobsDataMap[key],
                                                                      )));
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 10)
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                              )
                            : Material(
                                elevation: 20,
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  width: 370,
                                  constraints: BoxConstraints(
                                    minHeight: 60,
                                  ),
                                  child: Center(
                                    child: RichText(
                                      text: TextSpan(
                                        text: "No Shifts Found",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 20.0,
                                            color: Color(0xFFC5C5C5)),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
