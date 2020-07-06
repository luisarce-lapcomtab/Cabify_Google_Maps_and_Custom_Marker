import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:location/location.dart' as lct;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

//Ubicacion por defecto
const DEFAULT_LOCATION = LatLng(-2.142869, -79.923845);

class _MyHomePageState extends State<MyHomePage> {
  LatLng currentLocation = DEFAULT_LOCATION;
  Completer<GoogleMapController> _mapController = Completer();
  String finallat = "";
  String finallong = "";
  bool buscando = false;
  lct.Location location;

  @override
  void initState() {
    requestPerms();
    super.initState();
  }

//Permiso
  requestPerms() async {
    Map<Permission, PermissionStatus> statuses =
        await [Permission.locationAlways].request();

    var status = statuses[Permission.locationAlways];
    if (status == PermissionStatus.denied) {
      requestPerms();
    } else {
      gpsAnable();
    }
  }

// GPS
  gpsAnable() async {
    location = lct.Location();
    bool statusResult = await location.requestService();

    if (!statusResult) {
      gpsAnable();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: currentLocation,
                zoom: 15.2,
              ),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              minMaxZoomPreference: MinMaxZoomPreference(10.5, 16.9),
              onCameraMove: (CameraPosition camerapos) {
                buscando = false;
                setState(() {});
                finallat = camerapos.target.latitude.toString();
                finallong = camerapos.target.longitude.toString();
              },
              onMapCreated: (GoogleMapController controller) {
                _mapController.complete(controller);
              },
              onCameraIdle: () {
                buscando = true;
                setState(() {});
              },
            ),
            Align(
              alignment: Alignment.center,
              child: Image.asset(
                "assets/images/markeruser.png",
                height: 110,
              ),
            ),
            buscando == true
                ? Positioned(
                    top: MediaQuery.of(context).size.height / 3.1,
                    left: MediaQuery.of(context).size.width / 3.5,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                        color: Colors.black.withOpacity(0.75),
                      ),
                      width: 180,
                      height: 40,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Lat $finallat",
                            style: TextStyle(color: Colors.white),
                          ),
                          Text(
                            "Lng $finallong",
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  )
                : Positioned(
                    top: MediaQuery.of(context).size.height / 3.1,
                    left: MediaQuery.of(context).size.width / 2.3,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          vertical: 12.0, horizontal: 17.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                        color: Colors.black.withOpacity(0.75),
                      ),
                      width: 50,
                      height: 40,
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                          strokeWidth: 2.5,
                        ),
                      ),
                    ),
                  ),
            DraggableScrollableSheet(
                initialChildSize: 0.32,
                maxChildSize: 0.92,
                builder: (context, controler) {
                  return Container(
                    child: ListView(
                      controller: controler,
                      children: [
                        Divider(
                          height: 15,
                          thickness: 4,
                          color: Colors.grey[400],
                          indent: 185,
                          endIndent: 185,
                        ),
                        Container(
                          height: 50,
                          alignment: Alignment.center,
                          padding: EdgeInsets.only(left: 15),
                          margin: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: TextField(
                            enabled: false,
                            onTap: () {},
                            decoration: InputDecoration.collapsed(
                                hintText: " Where do you want to go?",
                                hintStyle: TextStyle(
                                    fontSize: 18, color: Colors.indigo[300],fontWeight: FontWeight.w500)),
                          ),
                        ),
                        DirecListTile("Home", (Icons.home)),
                        DirecListTile("Work", (Icons.work)),
                      ],
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                  );
                }),
          ],
        ),
      ),
    );
  }
}

class DirecListTile extends StatelessWidget {
  final String head;
  final IconData icon;

  DirecListTile(this.head, this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: InkWell(
        child: Padding(
          padding: const EdgeInsets.all(9.5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.black12,
                    child: Icon(
                      icon,
                      color: Colors.deepPurple,
                      size: 18,
                    ),
                    radius: 18,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          head,
                          style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),
                        ),
                        SizedBox(
                          height: 4.5,
                        ),
                        Text(
                          "Add as Favorite",
                          style:
                              TextStyle(color: Colors.deepPurple, fontSize: 14,fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  )
                ],
              )
            ],
          ),
        ),
        onTap: () {},
      ),
    );
  }
}
