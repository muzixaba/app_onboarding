import 'dart:io';
import 'package:app_onboarding/data/data.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main() => runApp(MyApp());


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
      initialRoute: "start",
      routes: {
        "start": (context) => StartScreen(),
        "/": (context) => OnboardingHomeScreen(),
        "VS": (context) => VerificationScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class StartScreen extends StatefulWidget {
  const StartScreen({Key key}) : super(key: key);

  @override
  _StartScreenState createState() => _StartScreenState();
}


class _StartScreenState extends State<StartScreen> {

/// Check if cell number saved before choosing next screen
  checkCell() async {
    WidgetsFlutterBinding.ensureInitialized();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String _code = await prefs.getString("enteredCell");
      print("The code is $_code");
     if(_code == null) {
      return Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CellNumEnterScreen()),
            );
    } else {
    return Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => OnboardingHomeScreen()),
            );
    }
  }

  @override
void initState() { 
  super.initState();
  checkCell();
}


  @override
  Widget build(BuildContext context) {
    return SafeArea(
          child: Scaffold(
            backgroundColor: Colors.white,
        body: Center(
          child: Container(
            child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FlutterLogo(
                  size: 200.0,
                ),
                SizedBox(
                  height: 20.0,
                ),
              CircularProgressIndicator(
                  strokeWidth: 6.0,
                  backgroundColor: Colors.white,
              ),
            ],)
          ),
        ),
      ),
    );
  }
}

class OnboardingHomeScreen extends StatefulWidget {
  @override
  _OnboardingHomeScreenState createState() => _OnboardingHomeScreenState();
}

class _OnboardingHomeScreenState extends State<OnboardingHomeScreen> {
  List<SliderModel> mySLides = new List<SliderModel>();
  int slideIndex = 0;
  PageController controller;

  /// set shared preference values
  void setValue(String key, String value) async {
    SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    // set shared pref
    sharedPrefs.setString(key, value);
  }

  Widget _buildPageIndicator(bool isCurrentPage) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 2.0),
      height: isCurrentPage ? 10.0 : 6.0,
      width: isCurrentPage ? 10.0 : 6.0,
      decoration: BoxDecoration(
        color: isCurrentPage ? Colors.grey : Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    mySLides = getSlides();
    controller = PageController();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [const Color(0xff3C8CE7), const Color(0xff00EAFF)])),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          height: MediaQuery.of(context).size.height - 100,
          child: PageView(
            controller: controller,
            onPageChanged: (index) {
              setState(() {
                slideIndex = index;
              });
            },
            children: <Widget>[
              SlideTile(
                imagePath: mySLides[0].getImageAssetPath(),
                title: mySLides[0].getTitle(),
                desc: mySLides[0].getDesc(),
              ),
              SlideTile(
                imagePath: mySLides[1].getImageAssetPath(),
                title: mySLides[1].getTitle(),
                desc: mySLides[1].getDesc(),
              ),
              SlideTile(
                imagePath: mySLides[2].getImageAssetPath(),
                title: mySLides[2].getTitle(),
                desc: mySLides[2].getDesc(),
              ),
            ],
          ),
        ),
        bottomSheet: slideIndex != 2
            ? Container(
                margin: EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    FlatButton(
                      onPressed: () {
                        // jump to 3rd page
                        controller.animateToPage(2,
                            duration: Duration(milliseconds: 400),
                            curve: Curves.linear);
                      },
                      splashColor: Colors.blue[50],
                      child: Text(
                        "SKIP",
                        style: TextStyle(
                            color: Color(0xFF0074E4),
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    Container(
                      // show page indicator
                      child: Row(
                        children: [
                          for (int i = 0; i < 3; i++)
                            i == slideIndex
                                ? _buildPageIndicator(true)
                                : _buildPageIndicator(false),
                        ],
                      ),
                    ),
                    FlatButton(
                      onPressed: () {
                        print("this is slideIndex: $slideIndex");
                        controller.animateToPage(slideIndex + 1,
                            duration: Duration(milliseconds: 500),
                            curve: Curves.linear);
                      },
                      splashColor: Colors.blue[50],
                      child: Text(
                        "NEXT",
                        style: TextStyle(
                            color: Color(0xFF0074E4),
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              )
            : InkWell(
                onTap: () {
                  //TODO: showDialog screen for user to confirm cell number
                  print("Must send user to VerificationScreen");
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CellNumEnterScreen(),
                    ),
                  );
                },
                child: Container(
                  height: Platform.isIOS ? 70 : 60,
                  color: Colors.blue,
                  alignment: Alignment.center,
                  child: Text(
                    "Done",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 20.0),
                  ),
                ),
              ),
      ),
    );
  }
}


class SlideTile extends StatelessWidget {
  final String imagePath, title, desc;

  SlideTile({this.imagePath, this.title, this.desc});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset(imagePath),
          SizedBox(
            height: 40,
          ),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
          ),
          SizedBox(
            height: 20,
          ),
          Text(desc,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14))
        ],
      ),
    );
  }
}


class CellNumEnterScreen extends StatelessWidget {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SlideTile(
                  imagePath: 'assets/phone.png',
                  title: "Your Cell Phone Number",
                  desc: "Please enter your cell number for verification",
                ),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: _controller,
                  // autofocus: true,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.phone, color: Colors.black45),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(),
                    ),
                    filled: true,
                  ),
                  keyboardType: TextInputType.phone,
                  // validator: validateCell,
                  onSaved: (value) => print(value),
                ),
              ],
            )),
        bottomSheet: InkWell(
          onTap: () {
            print("Submit tapped");
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => VerificationScreen(
                  enteredCell: _controller.text,
                ),
              ),
            );
          },
          child: Container(
            height: Platform.isIOS ? 70 : 60,
            color: Colors.blue,
            alignment: Alignment.center,
            child: Text(
              "Send Cell Number",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 20.0),
            ),
          ),
        ),
      ),
    );
  }
}

class VerificationScreen extends StatelessWidget {
  final _controller = TextEditingController();
  final String enteredCell;

  VerificationScreen({Key key, this.enteredCell}) : super(key: key);

      /// set shared preference values
  void setPref(String key, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SlideTile(
                  imagePath: 'assets/text.png',
                  title: "Enter Verification Code",
                  desc: "Enter the 4 digit code the was sent to $enteredCell via SMS",
                ),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: _controller,
                  // autofocus: true,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.verified, color: Colors.black45),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(),
                    ),
                    filled: true,
                  ),
                  keyboardType: TextInputType.phone,
                  // validator: validateCell,
                  // onSaved: (String value) => VerificationScreen(enteredCell: value),
                  onSaved: (value) => print(value),
                ),
                SizedBox(
                  height: 20,
                ),
                Text("resend code"),
              ],
            )),
        bottomSheet: InkWell(
          onTap: () {
            print("Submit tapped");
            print("cellEntered: ${_controller.text}");
            //TODO: send request to backend to verify verification code
            //TODO: If code is correct, generate token in backend, save cell num to app profile
            //TODO: navigate to Profile page
            //TODO: If code incorrect, return IncorrectCode Exception/Message, ask if to resend
            setPref("enteredCell", _controller.text);
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(builder: (context) => VerificationScreen()),
            // );
          },
          child: Container(
            height: Platform.isIOS ? 70 : 60,
            color: Colors.blue,
            alignment: Alignment.center,
            child: Text(
              "Submit",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 20.0),
            ),
          ),
        ),
      ),
    );
  }
}
