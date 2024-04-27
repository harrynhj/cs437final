import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class DetailScreen extends StatelessWidget {
  final String body_temp;
  final String pressure;
  final String altitude;
  final String room_temp;

  // Constructor
  const DetailScreen({
    Key? key,
    required this.body_temp,
    required this.pressure,
    required this.altitude,
    required this.room_temp,
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Stats")),
      body: ListView(
        children: <Widget>[
          const Card(
            child: ListTile(
              title: Text(
                'Body Temperature:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight:FontWeight.bold,
                ),
              ),
            ),

          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.thermostat),
              title: Text(room_temp + "C"),
            ),
          ),
          const Card(
            child: ListTile(
              title: Text(
                'Room Temperature:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight:FontWeight.bold,
                ),
              ),
            ),

          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.person),
              title: Text(body_temp + "C"),
            ),
          ),
          const Card(
            child: ListTile(
              title: Text(
                'Pressure:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight:FontWeight.bold,
                ),
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.speed),
              title: Text(pressure + "pascal"),
            ),
          ),
          const Card(
            child: ListTile(
              title: Text(
                'Altitude:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight:FontWeight.bold,
                ),
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.height),
              title: Text(altitude + "m"),
            ),
          ),
        ],
      ),
    );
  }
}