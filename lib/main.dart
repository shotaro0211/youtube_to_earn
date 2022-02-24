import 'dart:async';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_web3/flutter_web3.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'web_youtube.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Youtube to Earn',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Youtube to Earn'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Timer? _timer;
  int _time = 43;
  Contract? _contract;
  bool _isGiven = false;
  bool _isGot = false;
  bool? _isConnected;
  bool _isLoader = false;
  String _balance = "";

  @override
  void initState() {
    super.initState();
    startTimer();
    document.addEventListener("visibilitychange", (event) {
      if (document.visibilityState == "hidden") {
        _timer!.cancel();
      } else {
        startTimer();
      }
    });
    Future(() async {
      if (ethereum != null) {
        try {
          // Prompt user to connect to the provider, i.e. confirm the connection modal
          final accs = await ethereum!.requestAccount();
          final web3provider = Web3Provider(ethereum!);
          final network = await web3provider.getNetwork();
          final signer = web3provider.getSigner();
          const contractAddress = '0x707D798D13319F495f82E4222E546ee3d4E3F5e9';
          final abi = await rootBundle.loadString('json/youtube_to_earn.json');
          _contract = Contract(contractAddress, abi, signer);
          _contract!.call('balance').then((value) {
            setState(() {
              _balance = value.toString();
              _balance = _balance.substring(0, _balance.length - 18);
            });
          });
          if (network.chainId == 137) {
            _isConnected = true;
          } else {
            _isConnected = false;
          }
        } on EthereumUserRejected {
          print('User rejected the modal');
        }
      } else {
        _isConnected = false;
      }
    });
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), _onTimer);
  }

  void _onTimer(Timer timer) {
    setState(() {
      _time -= 1;
      if (_time == 0) {
        _timer!.cancel();
        _isGiven = true;
      }
    });
  }

  void _giveToken() {
    _contract!.call('giveToken', [211]).then((value) {
      _isLoader = false;
      _isGot = true;
    });
    _isLoader = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (ethereum != null)
              SizedBox(
                height: 80,
                child: Text('balance: $_balance JPYC',
                    style: Theme.of(context).textTheme.headline3),
              ),
            if (_isConnected == null)
              Container()
            else if (_isConnected == true)
              Stack(
                alignment: AlignmentDirectional.center,
                children: [
                  Column(
                    children: <Widget>[
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 800.0),
                        child: const SizedBox(
                          width: 800,
                          child: WebYoutube(),
                        ),
                      ),
                      const SizedBox(height: 30),
                      if (_isGot)
                        const Text('You got! Thank you!')
                      else if (_isLoader)
                        SpinKitRing(
                          size: 50,
                          color: Theme.of(context).primaryColor.withOpacity(1),
                        )
                      else if (_isGiven)
                        OutlinedButton(
                          child: Text('Get',
                              style: Theme.of(context).textTheme.headline4),
                          onPressed: () => _giveToken(),
                        )
                      else
                        Text(
                          'remain: ${_time.toString()} seconds',
                          style: Theme.of(context).textTheme.headline4,
                        ),
                    ],
                  ),
                ],
              )
            else
              Text(
                  ethereum != null
                      ? 'error: The network is not supported (only Polygon in supported).'
                      : "error: Can't connect to Metamask",
                  style: Theme.of(context).textTheme.headline4),
          ],
        ),
      ),
    );
  }
}
