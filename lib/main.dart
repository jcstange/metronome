import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:soundpool/soundpool.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Metronome',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Metronome'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int tempo = 60;
  Sound sound;
  Future<int> soundId;
  Beat beat;
  StreamSubscription subscription;
  bool isPlaying = false;

  @override
  void initState() {
    print("initState");
    sound = Sound();
    sound.init();
    soundId = sound.loadSound();
    super.initState();
  }

  @override
  void didUpdateWidget(MyHomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  void play() {
    if (beat == null) beat = Beat(tempo);
    setState(() {
      isPlaying = true;
    });
    subscribe();
  }

  void subscribe(){
    var startTime = DateTime.now().millisecondsSinceEpoch;
    subscription = beat.beat.stream.listen((data) {
      var sinceLastBeat = DateTime.now().millisecondsSinceEpoch - startTime;
      print('Since last beat = $sinceLastBeat');
      startTime = DateTime.now().millisecondsSinceEpoch;
      sound.playSound(soundId);
    });
  }

  void stop() {
    print("stop");
    setState(() {
      isPlaying = false;
    });
    subscription.cancel();
  }

  void increaseTempo() {
    setState(() {
      tempo = tempo+1;
    });
    updateBeat(tempo);
  }

  void reduceTempo() {
    setState(() {
      tempo = tempo-1;
    });
    updateBeat(tempo);
  }

  void updateBeat(int tempo) {
    print("New tempo: $tempo");
    subscription.cancel();
    beat = Beat(tempo);
    subscribe();
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
            Expanded(
                child:Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Center(child: Text(
                          'Tempo:',
                        )),
                        Center(child: Text(
                          '$tempo',
                          style: Theme.of(context).textTheme.headline4,
                        )),
                    ],))),
            Expanded(child: Center(
                child: Row(
              children: <Widget>[
                Expanded(
                    child: FloatingActionButton(
                        onPressed: reduceTempo,
                        tooltip: 'Reduce Tempo',
                        child: Icon(Icons.remove))),
                // This trailing comma makes auto-formatting nicer for build methods.
                Expanded(
                    child: FloatingActionButton(
                        onPressed: isPlaying ? stop : play,
                        tooltip: 'Increment',
                        child: isPlaying
                            ? Icon(Icons.pause)
                            : Icon(Icons.play_arrow))),
                // This trailing comma makes auto-formatting nicer for build methods.
                Expanded(
                    child: FloatingActionButton(
                        onPressed: increaseTempo,
                        tooltip: 'Increase Tempo',
                        child: Icon(Icons.add))),
                // This trailing comma makes auto-formatting nicer for build methods.
              ],
            )))
          ],
        ),
      ),
    );
  }
}

class Sound {
  Soundpool soundPool;

  void init() {
    instantiate();
  }

  Future<void> instantiate() async {
    WidgetsFlutterBinding.ensureInitialized();
    soundPool = Soundpool();
  }

  Future<int> loadSound() async {
    var asset = await rootBundle.load("assets/sounds/widefngr.wav");
    return await soundPool.load(asset);
  }

  Future<void> playSound(Future<int> soundId) async {
    var _sound = await soundId;
    await soundPool.play(_sound);
  }
}

class Beat {
  final int tempo;
  StreamController<void> beat = StreamController();

  Beat(this.tempo) {
    Timer.periodic(Duration(milliseconds: 60000 ~/ tempo), (t) {
      beat.add("");
    });
  }
}
