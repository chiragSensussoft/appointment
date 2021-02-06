import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: TestPage(),);
  }
}


class TestPage extends StatefulWidget {
  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {

  @override
  void initState() {
    super.initState();
    fetchLinkData();
  }

  void fetchLinkData() async {
    // FirebaseDynamicLinks.getInitialLInk does a call to firebase to get us the real link because we have shortened it.
    var link = await FirebaseDynamicLinks.instance.getInitialLink();

    // This link may exist if the app was opened fresh so we'll want to handle it the same way onLink will.
    handleLinkData(link);

    // This will handle incoming links if the application is already opened
    FirebaseDynamicLinks.instance.onLink(onSuccess: (PendingDynamicLinkData dynamicLink) async {
      handleLinkData(dynamicLink);
    });
  }

  void handleLinkData(PendingDynamicLinkData data) {
    final Uri uri = data?.link;
    if(uri != null) {
      final queryParams = uri.queryParameters;
      if(queryParams.length > 0) {
        String userName = queryParams["username"];
        String pass = queryParams['password'];
        // verify the username is parsed correctly
        print("My users username is: $userName");
        print("My users Password is: $pass");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sample"),
      ),
      body: Column(
        children:[
          Text(dynamicLink.toString()??""),
          FlatButton(
            color:
            Colors.blue,
            height: 100,
            onPressed: () async {
              _launchURL();
            },
            child: Text(dynamicLink.toString()??""),
          ),
        ]
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          dynamicLink = await createDynamicLink(userName:"test" ,pass:"test123");
          // dynamicLink has been generated. share it with others to use it accordingly.
          print("Dynamic Link: $dynamicLink");
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  _launchURL() async {
    var url = dynamicLink.toString();
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
  var dynamicLink;

  Future<Uri> createDynamicLink({@required userName,@required pass}) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      // This should match firebase but without the username query param
      uriPrefix: 'https://appointmrnt.page.link',
      link: Uri.parse('https://appointmrnt.page.link/appointment?username=$userName&password=$pass'),
      androidParameters: AndroidParameters(
        packageName: 'com.ck.appointment',
        minimumVersion: 1,
      ),
      iosParameters: IosParameters(
        bundleId: 'com.ck.appointment',
        minimumVersion: '1',
        appStoreId: '',
      ),
    );
    final link = await parameters.buildUrl();
    final ShortDynamicLink shortenedLink = await DynamicLinkParameters.shortenUrl(
      link,
      DynamicLinkParametersOptions(shortDynamicLinkPathLength: ShortDynamicLinkPathLength.unguessable),
    );
    return shortenedLink.shortUrl;
  }
}