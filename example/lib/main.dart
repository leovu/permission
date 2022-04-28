import 'package:flutter/material.dart';

import 'package:permission/permission.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {

  bool _isAllow = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Center(
          child: _isAllow?Text("Allowed Storage Permission"):MaterialButton(
              child: Text(
                  "Request Storage Permission"
              ),
              onPressed: () async {
                _isAllow = await PermissionRequest.request(PermissionRequestType.STORAGE, (){
                  showDialog(
                      context: context,
                      builder: (_){
                        return AlertDialog(
                          title: Text("Allowed to access"),
                          content: Text("Select Settings to App Information, select (Permissions), enable access and re-enter this screen to use Storage"),
                          actions: [
                            TextButton(
                                child: Text("Allow"),
                                onPressed: (){
                                  Navigator.of(context).pop();
                                  PermissionRequest.openSetting();
                                }
                            )
                          ],
                        );
                      }
                  );
                });

                setState(() {

                });
              }
          )
      ),
    );
  }
}
