import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_blue_app/DetailPage.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:fl_chart/fl_chart.dart';

class ChatPage extends StatefulWidget {
  final BluetoothDevice server;

  const ChatPage({required this.server});

  @override
  _ChatPage createState() => new _ChatPage();
}

class _Message {
  int whom;
  String text;

  _Message(this.whom, this.text);
}

class _ChatPage extends State<ChatPage> {
  // Variables for bluetooth connections
  static final clientID = 0;
  BluetoothConnection? connection;
  bool isConnecting = true;
  bool get isConnected => connection != null && connection!.isConnected;
  bool isDisconnecting = false;

  String _messageBuffer = '';
  List<FlSpot> heart_beat = [
    FlSpot(0, 0),
    FlSpot(1, 0),
    FlSpot(2, 0),
    FlSpot(3, 0),
    FlSpot(4, 0),
    FlSpot(5, 0),
    FlSpot(6, 0)
  ];

  List<FlSpot> oxygen_saturation = [
    FlSpot(0, 0),
    FlSpot(1, 0),
    FlSpot(2, 0),
    FlSpot(3, 0),
    FlSpot(4, 0),
    FlSpot(5, 0),
    FlSpot(6, 0)
  ];

  late String body_temp;
  late String pressure;
  late String altitude;
  late String room_temp;





  @override
  void initState() {
    super.initState();

    BluetoothConnection.toAddress(widget.server.address).then((_connection) {
      print('Connected to the device');
      connection = _connection;
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });

      connection!.input!.listen(_onDataReceived).onDone(() {
        // Example: Detect which side closed the connection
        // There should be `isDisconnecting` flag to show are we are (locally)
        // in middle of disconnecting process, should be set before calling
        // `dispose`, `finish` or `close`, which all causes to disconnect.
        // If we except the disconnection, `onDone` should be fired as result.
        // If we didn't except this (no flag set), it means closing by remote.
        if (isDisconnecting) {
          print('Disconnecting locally!');
        } else {
          print('Disconnected remotely!');
        }
        if (this.mounted) {
          setState(() {});
        }
      });
    }).catchError((error) {
      print('Cannot connect, exception occured');
      print(error);
    });
    _sendMessage('1');
  }

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and disconnect
    if (isConnected) {
      isDisconnecting = true;
      connection!.dispose();
      connection = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: (isConnecting ? Text('Connecting')
        : isConnected ? Text('Wristband Panel')
            : Text('Disconnected'))),
      body: Column(
        children: [
          Text("Heart Beat Graph (BPM)"),
          Padding(
              padding: const EdgeInsets.only(top: 5.0, bottom: 5.0)
          ),
          SizedBox(
            width: 400,
            height: 200,
            child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(show: true),
                  borderData: FlBorderData(show: true),
                  minX: 0,
                  maxX: 6,
                  minY: 0,
                  maxY: 200,
                  lineBarsData: [
                    LineChartBarData(
                      spots: heart_beat,
                      isCurved: false,
                      color: Colors.blue,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                )
            ),
          ),
          Padding(
              padding: const EdgeInsets.only(top: 10.0, bottom: 10.0)
          ),
          Text("oxygen saturation (%)"),
          Padding(
              padding: const EdgeInsets.only(top: 5.0, bottom: 5.0)
          ),
          SizedBox(
            width: 400,
            height: 200,
            child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(show: true),
                  borderData: FlBorderData(show: true),
                  minX: 0,
                  maxX: 6,
                  minY: 0,
                  maxY: 100,
                  lineBarsData: [
                    LineChartBarData(
                      spots: oxygen_saturation,
                      isCurved: false,
                      color: Colors.blue,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                )
            ),
          ),
          Padding(
              padding: const EdgeInsets.only(top: 5.0, bottom: 5.0)
          ),
          ElevatedButton(
            child: const Text('More Stats'),
            onPressed: () async {_jump_page(context);},
          ),
        ],
      )
    );
  }

  void _onDataReceived(Uint8List data) {
    // Allocate buffer for parsed data
    int backspacesCounter = 0;
    data.forEach((byte) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    });
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;
    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }



    // Create message if there is new line character
    String dataString = String.fromCharCodes(buffer);
    int index = buffer.indexOf(13);
    if (~index != 0) {
      dataString.substring(0, index);
    }
    final split = dataString.split(',');
    final Map<int, String> values = {
      for (int i = 0; i < split.length; i++)
        i: split[i]
    };
    setState(() {
      for (int i = 0; i < heart_beat.length-1; i++) {
        heart_beat[i] = FlSpot(i.toDouble() ,heart_beat[i+1].y);
        oxygen_saturation[i] = FlSpot(i.toDouble() ,oxygen_saturation[i+1].y);
      }
      if (double.parse(values[0]!) <= 10) {
        values[0] = '0.0';
      }
      if (double.parse(values[1]!) >= 100) {
        values[1] = '100.0';
      }
      if (double.parse(values[1]!) <= 10) {
        values[1] = '0.0';
      }
      heart_beat[heart_beat.length-1] = FlSpot(heart_beat.length-1, double.parse(values[0]!));
      oxygen_saturation[oxygen_saturation.length-1] = FlSpot(oxygen_saturation.length-1, double.parse(values[1]!));
      room_temp = values[2]!;
      pressure = values[3]!;
      altitude = values[4]!;
      body_temp = values[5]!;
    });

  }

  void _sendMessage(String text) async {
    text = text.trim();

    if (text.length > 0) {
      try {
        connection!.output.add(Uint8List.fromList(utf8.encode(text + "\r\n")));
        await connection!.output.allSent;
      } catch (e) {
        // Ignore error, but notify state
        setState(() {});
      }
    }
  }

  void _jump_page(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return DetailScreen(body_temp: body_temp, pressure: pressure, altitude: altitude, room_temp: room_temp);
        },
      ),
    );
  }
}




