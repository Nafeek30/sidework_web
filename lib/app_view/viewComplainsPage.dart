import 'package:flutter/material.dart';
import 'package:sidework_web/landing_view/loginPage.dart';
import 'package:sidework_web/utilities/constants.dart';

class ViewComplainsPage extends StatefulWidget {
  const ViewComplainsPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ViewComplainsPageState();
  }
}

class ViewComplainsPageState extends State<ViewComplainsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.sideworkBlue,
        title: const Text(
          'View Complains',
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
      body: Center(
        child: Text('Complains page'),
      ),
    );
  }
}
