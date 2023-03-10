import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';

import 'package:pretty_qr_code/pretty_qr_code.dart';

void main() => runApp(ExampleApp());

GlobalKey _globalKey = GlobalKey();

/// The example application class
class ExampleApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
    return MaterialApp(
      title: 'QR.Flutter',
      theme: ThemeData.light(),
      debugShowCheckedModeBanner: false,
      home: MainScreen(),
    );
  }
}

/// This is the screen that you'll see when the app starts
class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int itemIndex;

  @override
  void initState() {
    itemIndex = 0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: SafeArea(
        // top: true,
        bottom: true,
        child: Container(
          child: Column(
            children: <Widget>[
              const SizedBox(
                height: 100,
              ),
              ImageGenerator(
                item: listado[itemIndex],
              ),
              ElevatedButton(
                  onPressed: () async {
                    await _captureAndSavePng();
                    setState(() {
                      itemIndex = itemIndex + 1;
                    });
                  },
                  child: const Text('GuardarImagen ')),
              Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 40)
                          .copyWith(bottom: 40),
                  child: Text(itemIndex.toString())),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _captureAndSavePng() async {
    // RenderRepaintBoundary boundary =
    // _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    // double pixelRatio = MediaQuery.of(context).devicePixelRatio;
    // ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
    // ByteData? byteData =
    //     await image.toByteData(format: ui.ImageByteFormat.png);
    // var pngBytes = byteData!.buffer.asUint8List();

    RenderRepaintBoundary boundary =
        _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    double pixelRatio = MediaQuery.of(context).devicePixelRatio;
    ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);

    // ui.Image image = await boundary.toImage();
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();
    await [Permission.storage].request();
    await ImageGallerySaver.saveImage(
      pngBytes,
      name: listado[itemIndex]['file'],
      quality: 100,
    );
  }

  // Future<img.Image> _convertWidgetToImage(GlobalKey key) async {
  //   RenderRepaintBoundary boundary =
  //       key.currentContext!.findRenderObject() as RenderRepaintBoundary;
  //   ui.Image image = await boundary.toImage(pixelRatio: 3.0);
  //   ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  //   Uint8List pngBytes = byteData!.buffer.asUint8List();

  //   return img.decodeImage(pngBytes)!;
  // }

  // Future<File> _saveImage(img.Image image) async {
  //   final directory = await getExternalStorageDirectory();
  //   final imagePath = '${directory!.path}/my_image.png';
  //   File(imagePath).writeAsBytesSync(img.encodePng(image));
  //   return File(imagePath);
  // }

  // Future<void> _saveWidgetAsImage() async {
  //   img.Image image = await _convertWidgetToImage(_globalKey);
  //   File imageFile = await _saveImage(image);
  // }
}

class ImageGenerator extends StatelessWidget {
  const ImageGenerator({super.key, required this.item});

  final Map<String, String> item;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: _globalKey,
      child: MyWidget(
        item: item,
      ),
    );
  }
}

class MyWidget extends StatelessWidget {
  const MyWidget({super.key, required this.item});

  final Map<String, String> item;

  @override
  Widget build(BuildContext context) {
    const String logomundo = 'assets/images/mundo.svg';

    return Container(
      color: Colors.white,
      // height: 100,
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(5.0),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xff1e367c), width: 5),
                  // color: const Color(0xff1e367c),
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: PrettyQr(
                  elementColor: const Color(0xff1e367c),
                  typeNumber: 8,
                  size: 250,
                  data: item['link']!,
                  errorCorrectLevel: QrErrorCorrectLevel.M,
                  roundEdges: true,
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: Center(
                    child: Image.asset(
                  'assets/images/mundo.png',
                  scale: 1.3,
                )),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            width: 260,
            height: 50,
            decoration: BoxDecoration(
                color: const Color(0xff1e367c),
                borderRadius: BorderRadius.circular(5)),
            child: Center(
              child: Text(
                item['nombre']!,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<ui.Image> _loadOverlayImage() async {
    final completer = Completer<ui.Image>();
    final byteData = await rootBundle.load('assets/mundo.png');
    ui.decodeImageFromList(byteData.buffer.asUint8List(), completer.complete);
    return completer.future;
  }
}

final listado = [
  {
    'link':
        'https://estliveupsedu-my.sharepoint.com/:b:/g/personal/ptorresp_ups_edu_ec/EbtU-SSWoaRMj-1lhbgqLE0BFcKEMsHEFj-fjRtw8gnd4g?e=zlw0bb',
    'nombre': 'Manual UPS',
    'file': 'arc1'
  },
  {
    'link': 'https://forms.office.com/r/KDZMvqqpxn',
    'nombre': 'G1 D1 Entrada',
    'file': 'FormG1D1Ent-QRB'
  },
  {
    'link': 'https://forms.office.com/r/Nv9cL12Xxm',
    'nombre': 'G1 D1 Salida',
    'file': 'FormG1D1Sal-QRB'
  },
  {
    'link': 'https://forms.office.com/r/A70XEF1mCX',
    'nombre': 'G1 D2 Entrada',
    'file': 'FormG1D2Ent-QRB'
  },
  {
    'link': 'https://forms.office.com/r/cKjtkvLe7a',
    'nombre': 'G1 D2 Salida',
    'file': 'FormG1D2Sal-QRB'
  },
  {
    'link': 'https://forms.office.com/r/bmkwUc0rtc',
    'nombre': 'G2 D1 Entrada',
    'file': 'FormG2D1Ent-QRB'
  },
  {
    'link': 'https://forms.office.com/r/R6i3dLRVic',
    'nombre': 'G2 D1 Salida',
    'file': 'FormG2D1Sal-QRB'
  },
  {
    'link': 'https://forms.office.com/r/AETxXGXZV7',
    'nombre': 'G2 D2 Entrada',
    'file': 'FormG2D2Ent-QRB'
  },
  {
    'link': 'https://forms.office.com/r/kvRK7Vu1JU',
    'nombre': 'G2 D2 Salida',
    'file': 'FormG2D2Sal-QRB'
  },
  {
    'link': 'https://forms.office.com/r/CPrhQ6d202',
    'nombre': 'G3 D1 Entrada',
    'file': 'FormG3D1Ent-QRB'
  },
  {
    'link': 'https://forms.office.com/r/4qNKDHmgKs',
    'nombre': 'G3 D1 Salida',
    'file': 'FormG3D1Sal-QRB'
  },
  {
    'link': 'https://forms.office.com/r/XS2tSD8dYb',
    'nombre': 'G3 D2 Entrada',
    'file': 'FormG3D2Ent-QRB'
  },
  {
    'link': 'https://forms.office.com/r/9y8RrjMZNu',
    'nombre': 'G3 D2 Salida',
    'file': 'FormG3D2Sal-QRB'
  },
  {
    'link': 'https://forms.office.com/r/xcfj9K53Kr',
    'nombre': 'G4 D1 Entrada',
    'file': 'FormG4D1Ent-QRB'
  },
  {
    'link': 'https://forms.office.com/r/M3SiNtNDr6',
    'nombre': 'G4 D1 Salida',
    'file': 'FormG4D1Sal-QRB'
  },
  {
    'link': 'https://forms.office.com/r/Nvbrz3unRU',
    'nombre': 'G4 D2 Entrada',
    'file': 'FormG4D2Ent-QRB'
  },
  {
    'link': 'https://forms.office.com/r/1BQ1VC0dD2',
    'nombre': 'G4 D2 Salida',
    'file': 'FormG4D2Sal-QRB'
  },
];
