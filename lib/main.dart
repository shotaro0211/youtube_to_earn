import 'dart:async';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter_web3/flutter_web3.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

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
  bool _visible = false;
  final YoutubePlayerController _controller = YoutubePlayerController(
    initialVideoId: 'N0tNPT-3gLE',
    params: const YoutubePlayerParams(
      mute: true,
      playlist: [
        'N0tNPT-3gLE',
      ],
      loop: true,
    ),
  );

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
          print(accs.first);
          final web3provider = Web3Provider(ethereum!);
          final signer = web3provider.getSigner();
          const contractAddress = '0x794372fC0aE0E8927629c6fa606B99C65c91D6CC';
          final abi = await rootBundle.loadString('json/ERC20.json');
          Contract(contractAddress, abi, signer);
        } on EthereumUserRejected {
          print('User rejected the modal');
        }
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
        _visible = true;
      }
    });
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
            SizedBox(
              height: 600,
              child: YoutubePlayerControllerProvider(
                controller: _controller,
                child: const YoutubePlayerIFrame(),
              ),
            ),
            const SizedBox(height: 30),
            if (_visible)
              OutlinedButton(
                child: const Text('Get'),
                onPressed: () => null,
              )
            else
              Text(
                'remain: ${_time.toString()} seconds',
                style: Theme.of(context).textTheme.headline4,
              ),
          ],
        ),
      ),
    );
  }
}
