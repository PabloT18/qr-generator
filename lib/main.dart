import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:jovial_svg/jovial_svg.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';

import 'package:pretty_qr_code/pretty_qr_code.dart';

void main() => runApp(ExampleApp());

GlobalKey _globalKey = GlobalKey();

class ExampleApp extends StatelessWidget {
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
                height: 60,
                clipBehavior: Clip.hardEdge,
                padding: const EdgeInsets.all(5),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                // child: Center(
                //     child: Image.asset(
                //   'assets/images/mundo.png',
                //   scale: 1.3,
                // )),
                child: FutureBuilder<ScalableImage>(
                    future: ScalableImage.fromSvgAsset(rootBundle, logomundo),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Center(
                            child: ScalableImageWidget(
                          si: snapshot.data!,
                          fit: BoxFit.contain,
                          // scale: 1.3,
                        ));
                      } else {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    }),
              )
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
  // {
  //   'link': 'https://forms.office.com/r/mEWi3RZHgw',
  //   'nombre': 'D1 Mañ Entrada',
  //   'file': 'FormD1MañEnt-QRB'
  // },
  // {
  //   'link':
  //       'https://estliveupsedu-my.sharepoint.com/:b:/g/personal/ptorresp_ups_edu_ec/EV7_u_vZGBxIvMQRwPP1V-MBQ1rXQFqbbG4bslbKvIMKEA?e=Pxbiua',
  //   'nombre': 'Agenda',
  //   'file': 'Agenda-QRB'
  // },
  {
    'link': 'https://forms.office.com/r/K99b8sw5xi',
    'nombre': 'Ubicación Inglés',
    'file': 'UbicaciónInglés-QR'
  },
  {
    'link': 'https://forms.office.com/r/kPzgvgsyXB',
    'nombre': 'D1 Tar Salida',
    'file': 'FormD1TarSal-QRB'
  },
  {
    'link': 'https://forms.office.com/r/iUgzbRkPnR',
    'nombre': 'D2 Mañ Entrada',
    'file': 'FormD2MañEnt-QRB'
  },
  {
    'link': 'https://forms.office.com/r/cj55t0Tn1U',
    'nombre': 'D2 Mañ Salida',
    'file': 'FormD2MañSal-QRB'
  },
  {
    'link': 'https://forms.office.com/r/aKFhTCLVjc',
    'nombre': 'D2 Tar Entrada',
    'file': 'FormD2TarEnt-QRB'
  },
  {
    'link': 'https://forms.office.com/r/PgBWWB1Qm8',
    'nombre': 'D2 Tar Salida',
    'file': 'FormD2TarSal-QRB'
  },
];
