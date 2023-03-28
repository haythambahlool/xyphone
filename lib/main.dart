import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_midi/flutter_midi.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:piano/piano.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark),
  );
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: MyApp()));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _flutterMidi = FlutterMidi();
  final TextEditingController _ctrlnum = TextEditingController();

  void load(String asset) async {
    _flutterMidi.unmute();
    ByteData _byte = await rootBundle.load(asset);
    _flutterMidi.prepare(
        sf2: _byte, name: paths[_value].replaceAll('assets/', ''));
  }

  List<String> paths = [
    'assets/Expressive Flute SSO-v1.2.sf2',
    'assets/Yamaha-Grand-Lite-SF-v1.1.sf2',
    'assets/Best of Guitars-4U-v1.0.sf2',
  ];
  List<String> titles = ['Flute', 'Piano', 'Guitar'];
  late int _value;
  late int _title;

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  Future<void> _makeemail(String email) async {
    final Uri launchUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    await launchUrl(launchUri);
  }

  Future<void> _openmap(String longt, String lott) async {
    String googlemap =
        'https://www.google.com/maps/search/?api=1&query=$lott,$longt';
    await canLaunchUrlString(googlemap)
        ? await launchUrlString(googlemap)
        : throw 'could not launch $googlemap';
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  getlocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    longt = '${position.longitude} ';
    lott = '${position.latitude}';
  }

  Widget? valuechoose;
  String? longt;
  String? lott;

  @override
  void initState() {
    // valuechoose = LItems[0];
    _value = 0;
    _title = 0;
    //_title = titles[0];
    _ctrlnum.text = '0567243735';
    if (!kIsWeb) {
      load(paths[_value]);
    } else {
      _flutterMidi.prepare(sf2: null);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> LItems = [
      ListTile(
        leading: const Icon(
          Icons.call,
          color: Colors.teal,
        ),
        title: const Text(
          'Call',
          style: TextStyle(
            color: Colors.teal,
          ),
        ),
        onTap: () {
          _makePhoneCall('+972597243735');
        },
      ),
      ListTile(
        leading: const Icon(
          Icons.mail,
          color: Colors.teal,
        ),
        title: const Text(
          'Mail',
          style: TextStyle(
            color: Colors.teal,
          ),
        ),
        onTap: () {
          _makeemail('hetham@example.com');
        },
      ),
      ListTile(
        leading: const Icon(
          Icons.location_on,
          color: Colors.teal,
        ),
        title: const Text(
          'Location',
          style: TextStyle(
            color: Colors.teal,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: () async {
          await getlocation();
          showDialog(
            context: context,
            builder: (BuildContext context) => _buildPopupDialog(context),
          );
        },
      ),
    ];
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          leadingWidth: 170,
          backgroundColor: Colors.teal,
          leading: DropdownButton<Widget>(
            elevation: 0,
            borderRadius: BorderRadius.circular(20),
            underline: SizedBox(),
            hint: const Icon(
              Icons.more_vert,
              size: 30,
            ),
            iconSize: 1,
            isExpanded: true,
            alignment: AlignmentDirectional.centerStart,
            dropdownColor: Colors.white,
            value: valuechoose,
            items: LItems.map(
              (valueitem) {
                return DropdownMenuItem(
                  value: valueitem,
                  child: valueitem,
                );
              },
            ).toList(),
            onChanged: (value) {},
          ),
          title: Text(titles[_title]),
          actions: [
            DropdownButton<int>(
              elevation: 0,
              dropdownColor: Colors.teal,
              value: _value,
              iconEnabledColor: Colors.white,
              items: [
                DropdownMenuItem(
                  value: 0,
                  child: Text(
                    titles[0],
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                DropdownMenuItem(
                  value: 1,
                  child: Text(
                    titles[1],
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                DropdownMenuItem(
                  value: 2,
                  child: Text(
                    titles[2],
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
              onChanged: (int? value) {
                setState(() {
                  _title = value!;
                  _value = value;
                  load(paths[_value]);
                });
              },
            )
          ],
        ),
        body: SafeArea(
          child: Center(
            child: InteractivePiano(
              highlightedNotes: [NotePosition(note: Note.C, octave: 3)],
              naturalColor: Colors.white,
              accidentalColor: Colors.black,
              keyWidth: 50,
              noteRange:
                  NoteRange.forClefs([Clef.Treble, Clef.Alto, Clef.Bass]),
              onNotePositionTapped: (position) async {
                _play(position.pitch + 10);
                _stop(position.pitch + 9);
              },
            ),
          ),
        ),
      ),
    );
  }

  void _play(int midi) {
    if (kIsWeb) {
      // WebMidi.play(midi);
    } else {
      _flutterMidi.playMidiNote(midi: midi);
    }
  }

  void _stop(int midi) async {
    if (kIsWeb) {
    } else {
      await _flutterMidi.stopMidiNote(midi: midi);
    }
  }

  Widget _buildPopupDialog(BuildContext context) {
    return AlertDialog(
      title: const Center(
        child: Text(
          'Current Location',
        ),
      ),
      backgroundColor: Colors.white,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[Text("longitude: $longt"), Text("latitude: $lott")],
      ),
      actions: <Widget>[
        Center(
          child: ElevatedButton(
            onPressed: () {
              _openmap(longt!, lott!);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              elevation: 0.0,
              fixedSize: Size(150, 35),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              side: BorderSide(color: Colors.white),
            ),
            child: const Text(
              "Open in The Map",
            ),
          ),
        ),
      ],
    );
  }
}
