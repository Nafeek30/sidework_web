import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sidework_web/landing_view/loginPage.dart';
import 'package:sidework_web/utilities/constants.dart';

class ViewUsersPage extends StatefulWidget {
  const ViewUsersPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ViewUsersPageState();
  }
}

class ViewUsersPageState extends State<ViewUsersPage> {
  bool finishLoading = false;
  List allUsers = [];

  @override
  void initState() {
    super.initState();
    getInitialData();
  }

  @override
  void dispose() {
    allUsers.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.sideworkBlue,
        title: const Text(
          'View Users',
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
          ? allUsers.isEmpty
              ? Container(
                  margin: const EdgeInsets.only(top: 32),
                  child: const Text(
                    'No users found',
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: allUsers.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Text(
                          '${allUsers[index].data()['firstName']} ${allUsers[index].data()['lastName']}'),
                      subtitle: Text(
                        'Email: ${allUsers[index].data()['email']} | Phone: ${allUsers[index].data()['phoneNumber']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Constants.sideworkButtonOrange,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          textStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () {
                          executeBanOrUnban(allUsers[index].id,
                              allUsers[index].data()['isBanned']);
                        },
                        child: allUsers[index].data()['isBanned']
                            ? const Text('Unban')
                            : const Text('Ban'),
                      ),
                    );
                  })
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  getInitialData() async {
    try {
      FirebaseFirestore.instance
          .collection("users")
          .get()
          .then((querySnapshot) {
        for (var doc in querySnapshot.docs) {
          allUsers.add(doc);
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

  Future<void> executeBanOrUnban(String uid, bool currentStatus) async {
    try {
      FirebaseFirestore.instance.collection("users").doc(uid).update({
        'isBanned': !currentStatus,
      }).then((value) {
        setState(() {
          allUsers.clear();
          getInitialData();
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
}
