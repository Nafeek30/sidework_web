import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sidework_web/landing_view/loginPage.dart';
import 'package:sidework_web/utilities/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewComplainsPage extends StatefulWidget {
  const ViewComplainsPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ViewComplainsPageState();
  }
}

class ViewComplainsPageState extends State<ViewComplainsPage> {
  bool finishLoading = false;
  List allTickets = [];

  @override
  void initState() {
    super.initState();
    getInitialData();
  }

  @override
  void dispose() {
    allTickets.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.sideworkBlue,
        title: const Text(
          'View Complaints',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const LoginPage()));
            },
            style: ElevatedButton.styleFrom(
              primary: Constants.sideworkBlue,
            ),
            child: const Text(
              'Logout',
            ),
          ),
        ],
      ),
      body: finishLoading
          ? allTickets.isEmpty
              ? Container(
                  margin: const EdgeInsets.only(top: 32),
                  child: const Center(
                    child: Text(
                      'No complaints found',
                    ),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: allTickets.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Text(
                        'Report from: ${allTickets[index].data()['reportedBy'].toString().toUpperCase()}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        'Booking ID: ${allTickets[index].data()['bookingId'].toString()}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      trailing: GestureDetector(
                        onTap: () {
                          launchOptions(allTickets, index);
                        },
                        child: const Icon(
                          Icons.more_vert_rounded,
                          color: Constants.sideworkBlue,
                        ),
                      ),
                    );
                  })
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  /// Get initial users who made complaints from tickets collection in Firestore
  getInitialData() async {
    allTickets.clear();
    try {
      FirebaseFirestore.instance
          .collection("tickets")
          .get()
          .then((querySnapshot) {
        for (var doc in querySnapshot.docs) {
          allTickets.add(doc);
        }
        setState(() {
          finishLoading = true;
        });
      });
    } catch (e) {
      Fluttertoast.showToast(
        msg: e.toString(),
        backgroundColor: Constants.sideworkBlue,
        textColor: Constants.lightTextColor,
      );
    }
  }

  /// Launch dialog to email [reportedBy], [otherPerson] and buttons to [resolve] or [close]
  Future<void> launchOptions(List tickets, int index) async {
    return await showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: const Text(
                'Options',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Constants.sideworkBlue,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const Text(
                          'Reported by: ',
                          style: TextStyle(
                            color: Constants.sideworkGrey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            await launch(
                                'mailto:${tickets[index].data()['reportedBy']}');
                          },
                          child: Text(
                            tickets[index].data()['reportedBy'],
                            style: const TextStyle(
                              color: Constants.sideworkBlue,
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const Text(
                          'Other party: ',
                          style: TextStyle(
                            color: Constants.sideworkGrey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            await launch(
                                'mailto:${tickets[index].data()['otherPerson']}');
                          },
                          child: Text(
                            tickets[index].data()['otherPerson'],
                            style: const TextStyle(
                              color: Constants.sideworkBlue,
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Constants.sideworkGreen,
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    resolve(tickets, index, 1);
                  },
                  child: const Text('Refund'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Constants.lightRed,
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    resolve(tickets, index, 2);
                  },
                  child: const Text('Close'),
                ),
              ],
            );
          });
        });
  }

  /// Function takes in [status 1 == refund] or [status 2 == close] and performs a refund if needed and then deletes the ticket
  Future<void> resolve(List tickets, int index, int status) async {
    try {
      if (status == 1) {
        FirebaseFirestore.instance
            .collection('bookings')
            .doc(tickets[index].data()['bookingId'])
            .update({'totalPrice': 0}).then((booking) {
          deleteTicket(tickets[index].id);
        });
      } else if (status == 2) {
        deleteTicket(tickets[index].id);
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: e.toString(),
        backgroundColor: Constants.sideworkBlue,
        textColor: Constants.lightTextColor,
      );
    }
  }

  /// Function deletes tickets from the admin complaints screen and deletes the document from tickets collection
  Future<void> deleteTicket(String ticketId) async {
    try {
      FirebaseFirestore.instance
          .collection('tickets')
          .doc(ticketId)
          .delete()
          .then((value) {
        Navigator.pop(context);
        getInitialData();
        Fluttertoast.showToast(
          msg: 'Ticket deleted.',
          backgroundColor: Constants.sideworkBlue,
          textColor: Constants.lightTextColor,
        );
      });
    } catch (e) {
      Fluttertoast.showToast(
        msg: e.toString(),
        backgroundColor: Constants.sideworkBlue,
        textColor: Constants.lightTextColor,
      );
    }
  }
}
