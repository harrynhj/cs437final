import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import './ChatPage.dart';
//import './ChatPage2.dart';


class MainPage extends StatefulWidget {
  @override
  _MainPage createState() => new _MainPage();
}

class _MainPage extends State<MainPage> {


  bool connected = false;
  BluetoothDevice? _device;

  @override
  void initState() {
    super.initState();

    FlutterBluetoothSerial.instance
        .getBondedDevices()
        .then((List<BluetoothDevice> bondedDevices) {
      setState(() {
        for(BluetoothDevice device in bondedDevices){
          if (device.name == "raspberrypi"){
            _device = device;
          }
        }
      });
    });
  }


  @override
  void dispose() {
    FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: ListView(
          children: <Widget>[
            ListTile(
              title: Center(
                child: Text(
                  "Smart Wristband",
                  style: TextStyle(
                      fontSize: 32.0,
                  ),
                ),
              ),
            ),
            Padding(
                padding: const EdgeInsets.only(top: 10.0, bottom: 10.0)),
            Container(
              child: Image(
                image: AssetImage('img/smart-watch.png'),
                fit: BoxFit.contain,
              ),
            ),
            Padding(
                padding: const EdgeInsets.only(top: 30.0, bottom: 30.0)),
            ListTile(
              title: ElevatedButton(
                child: const Text('Connect'),
                onPressed: () async {
                  if (_device != null) {
                    print('Connect -> selected ' + _device!.address);
                    _startChat(context, _device!);
                  } else {
                    print('Connect -> no device selected');
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startChat(BuildContext context, BluetoothDevice server) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return ChatPage(server: server);
        },
      ),
    );
  }
}
