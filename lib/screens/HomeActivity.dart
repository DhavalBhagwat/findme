import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:findme/widgets/InfoSection.dart';
import 'package:findme/sync/NetworkService.dart';
import 'package:findme/widgets/LoadingIndicator.dart';

class HomeActivity extends StatefulWidget {

  @override
  _HomeActivityState createState() => _HomeActivityState();

}

class _HomeActivityState extends State<HomeActivity> {

  String? _location = "", _timeZone = "", _isp = "";
  double? _latitude = 0.0, _longitude = 0.0;
  TextEditingController? _ipAddress;
  Future<void>? _get;

  @override
  void initState() {
    _ipAddress = TextEditingController();
    _get = _getIPLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildTopBar(),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) => Stack(
    children: [
      Column(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepPurpleAccent, Colors.deepPurpleAccent
                  ],
                ),
              ),
              child: Column(
                  children: [
                    _buildSearchBar(),
                  ],
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Container(
              child: FutureBuilder<void>(
                future: _get,
                builder: (context, snapshot) => snapshot.connectionState == ConnectionState.done ? FlutterMap(
                  options: MapOptions(
                    center: LatLng(_latitude!, _longitude!),
                    zoom: 12.0,
                  ),
                  layers: [
                    TileLayerOptions(
                      urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: ['a', 'b', 'c'],
                      tileProvider: NonCachingNetworkTileProvider(),
                    ),
                    MarkerLayerOptions(
                      markers: [
                        Marker(
                          width: 20.0,
                          height: 20.0,
                          point:  LatLng(_latitude!, _longitude!),
                          builder: (ctx) => SvgPicture.asset("assets/icon-location.svg", semanticsLabel: 'Marker'
                          ),
                        ),
                      ],
                    ),
                  ],
                ): LoadingIndicator(),
              ),
            ),
          ),
        ],
      ),
      buildInfoCard()
    ],
  );

  Widget buildInfoCard() => Positioned(
      top: MediaQuery.of(context).size.height * 0.10,
      left: 20.0,
      right: 20.0,
      child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InfoSection(title: "IP ADDRESS", value: _ipAddress?.value.text),
                InfoSection(title: "LOCATION", value: _location!),
                InfoSection(title: "TIME ZONE", value: _timeZone!),
                InfoSection(title: "ISP", value: _isp!),
              ],
            ),
          ),
      ),
  );

  PreferredSizeWidget _buildTopBar() => CupertinoNavigationBar(
    backgroundColor: Colors.deepPurpleAccent,
    border: Border(),
    middle: Text(
      'IP Address Tracker',
      style: TextStyle(
          color: Colors.white,
          fontSize: 20.0,
          fontWeight: FontWeight.bold
      ),
    ),
  );

  Widget _buildSearchBar() => Padding(
    padding: EdgeInsets.only(left: 15.0, right: 15.0),
    child: Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(18.0),
      child: TextFormField(
          decoration: InputDecoration(
              border: InputBorder.none,
              suffixIcon: Container(
                decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(18.0),
                        bottomRight: Radius.circular(18.0)
                    ),
                ),
                child: GestureDetector(
                  child: Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: 20.0
                  ),
                  onTap: () {
                    _get = _getIPLocation();
                  },
                ),
              ),
              contentPadding: EdgeInsets.only(left: 15.0, top: 15.0),
              hintText: 'Search IP',
              hintStyle: TextStyle(color: Colors.grey)
          ),
          keyboardType: TextInputType.number
      ),
    ),
  );

  Future<void> _getIPLocation() async {
    await NetworkService.getInstance.getIPLocation(ipAddress: _ipAddress!.value.text).then((location) {
      print(location?.toJson());
      setState(() {
        _location = location?.city;
        _timeZone = location?.timeZone;
        _isp = location?.isp;
        _latitude = location?.latitude;
        _longitude = location?.longitude;
        _ipAddress!.text = location!.ip!;
      });
    });

  }

}
