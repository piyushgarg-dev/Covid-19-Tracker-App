import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_country_picker/flutter_country_picker.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Covid 19',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xff473F97)
      ),
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  String _selectedCountryName;
  int _selectedIndex = 0;
  Position position;
  
  CovidData covidData;

//  Covid data
  String _affected = "N/A";
  String _death = "N/A";
  String _recovered = "N/A";
  String _active = "N/A";

  void getApiData(String country) async {
    String url = "https://api.covid19api.com/country/${country}";
    final response = await http.get(url);
    final parsed = json.decode(response.body);

    List<CovidData> covid_data = (parsed as List).map((e) => new CovidData(
      Active: e['Active'],
      Confirmed: e['Confirmed'],
      Country: e['Country'],
      Date: e['Date'],
      Deaths: e['Deaths'],
      Recovered: e['Deaths']
    )).toList();

    int recover_sum = 0;
    int active_sum = 0;
    int affected_sum = 0;
    int death_sum = 0;

    covid_data.forEach((value) => recover_sum = recover_sum + value.Recovered);
    covid_data.forEach((value) => active_sum = active_sum + value.Active);
    covid_data.forEach((value) => affected_sum = affected_sum + value.Confirmed);
    covid_data.forEach((value) => death_sum = death_sum + value.Deaths);

    setState(() {
      _recovered = recover_sum.toString();
      _active = active_sum.toString();
      _affected = affected_sum.toString();
      _death = death_sum.toString();
    });
    
    
    
  }

  void getCurrentLocation()async {
    position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.medium);
    final coordinates = new Coordinates(position.latitude, position.longitude);
    final addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
    setState(() {
      _selectedCountryName = addresses.first.countryName;
    });
    getApiData(addresses.first.countryName);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentLocation();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _selectedIndex == 0 ? Colors.white : Color(0xff473F97),
      key: _scaffoldKey,
      appBar: AppBar(
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(Icons.sort),
          onPressed: (){
            _scaffoldKey.currentState.openDrawer();
          },
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
            child: Icon(Icons.notifications),
          )
        ],
      ),
      drawer: Drawer(
        child: ListView(),
      ),
      body: _selectedIndex == 0 ? _homeScreen() : _statsScreen(),
     bottomNavigationBar: _bottomNavigation(),
    );
  }

//  Screens
   Widget _homeScreen() {
    return ListView(
      children: <Widget>[
        _headContainer(),
        _bodyContainer()
      ],
    );
  }

  Widget _statsScreen() {

    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: ListView(
        children: <Widget>[
          Text('Statistics', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),),
          SizedBox(height: 20,),
          Container(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Color(0xffFFB259),
            ),
            height: 120,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Affected', style: TextStyle(color: Colors.white, fontSize: 26 ,fontWeight: FontWeight.bold),),
                Flexible(child: Text(_affected,style: TextStyle(color: Colors.white, fontSize: 36 ,fontWeight: FontWeight.bold))),
              ],
            ),
          ),
          SizedBox(height: 10,),
          Container(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Color(0xffFF5959),
            ),
            height: 120,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Death', style: TextStyle(color: Colors.white, fontSize: 26 ,fontWeight: FontWeight.bold),),
                Flexible(child: Text(_death,style: TextStyle(color: Colors.white, fontSize: 36 ,fontWeight: FontWeight.bold))),
              ],
            ),
          ),
          SizedBox(height: 10,),
          Container(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Color(0xff4CD97B),
            ),
            height: 120,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Recovered', style: TextStyle(color: Colors.white, fontSize: 26 ,fontWeight: FontWeight.bold),),
                Flexible(child: Text(_recovered,style: TextStyle(color: Colors.white, fontSize: 36 ,fontWeight: FontWeight.bold))),
              ],
            ),
          ),
          SizedBox(height: 10,),
          Container(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Color(0xff4DB5FF),
            ),
            height: 120,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Active', style: TextStyle(color: Colors.white, fontSize: 26 ,fontWeight: FontWeight.bold),),
                Flexible(child: Text(_active,style: TextStyle(color: Colors.white, fontSize: 36 ,fontWeight: FontWeight.bold))),
              ],
            ),
          ),
        ],
      ),
    );
  }

//  Components
  Widget _headContainer() {
    return Container(
      padding: EdgeInsets.all(20),
      height: 300,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        )
      ),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Covid-19',
                style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
              ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20)
              ),
              child: Text(_selectedCountryName)
            )
            ],
          ),
          SizedBox(height: 40,),
          Row(
            children: <Widget>[
              Text(
                  'Are you feeling sick?',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
              )
            ],
          ),
          SizedBox(height: 15,),
          Row(
            children: <Widget>[
              Flexible(
                child: Text(
                    'If you feel sick with any of covid-19 symptoms please call or SMS us immediately for help.',
                  style: TextStyle(color: Colors.white70,),
                ),
              ),
            ],
          ),
          SizedBox(height: 25,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              FlatButton(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                color: Color(0xffFF4D58),
                onPressed: (){},
                child: Row(
                  children: <Widget>[
                    Icon(Icons.phone, color: Colors.white,),
                    SizedBox(width: 10,),
                    Text('Call Now', style: TextStyle(color: Colors.white),)
                  ],
                ),
              ),
              FlatButton(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                color: Color(0xff4D79FF),
                onPressed: (){},
                child: Row(
                  children: <Widget>[
                    Icon(Icons.sms, color: Colors.white,),
                    SizedBox(width: 10,),
                    Text('Send SMS', style: TextStyle(color: Colors.white),)
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bodyContainer() {
    return Container(
      margin: EdgeInsets.only(top: 20),
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Prevention', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
          SizedBox(height: 25,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Column(

                children: <Widget>[
                  Image.asset('assets/images/XMLID 80.png'),
                  SizedBox(height: 10,),
                  Text('Avoid close contact', style: TextStyle(fontWeight: FontWeight.bold),)
                ],
              ),
              Column(
                children: <Widget>[
                  Image.asset('assets/images/XMLID 15.png'),
                  SizedBox(height: 10,),
                  Text('Clean your hands often', style: TextStyle(fontWeight: FontWeight.bold),)
                ],
              ),
            ],
          ),
          SizedBox(height: 30,),
          Center(
            child: Container(
              child: Image.asset('assets/images/Group 32.png'),
            ),
          )
        ],
      ),
    );
  }

  Widget _bottomNavigation() {
    return BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 30,),
            title: Text('')
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.insert_chart, size: 30,),
              title: Text('')
          )
        ],
    );
  }
}


class CovidData {
  String Country;
  int Confirmed = 0;
  int Deaths = 0;
  int Recovered = 0;
  int Active = 0;
  String Date = "";

  CovidData({this.Country, this.Confirmed, this.Active, this.Date, this.Deaths, this.Recovered});


}