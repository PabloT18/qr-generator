import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:jovial_svg/jovial_svg.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';

import 'package:pretty_qr_code/pretty_qr_code.dart';

void main() => runApp(const App());

GlobalKey _globalKey = GlobalKey();

class App extends StatelessWidget {
  const App({super.key});

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
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  late int itemIndex;

  late bool itemCustom;
  late Map<String, String> itemCustomMap;

  @override
  void initState() {
    itemIndex = 0;
    itemCustom = false;
    itemCustomMap = {
      'link': '',
      'nombre': '',
      'file': '',
    };
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              const SizedBox(
                height: 30,
              ),
              ImageGenerator(
                item: itemCustom ? itemCustomMap : listado[itemIndex],
              ),
              const Divider(),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(itemIndex.toString())),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 21,
                    ),
                    TextField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        labelText: 'Link',
                        hintText: 'Link',

                        // prefixIcon: Icon(icon),
                      ),
                      onChanged: (value) {
                        itemCustomMap['link'] = value;
                      },
                    ),
                    const SizedBox(
                      height: 21,
                    ),
                    TextField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        labelText: 'Name',
                        hintText: 'Name',

                        // prefixIcon: Icon(icon),
                      ),
                      onChanged: (value) {
                        itemCustomMap['nombre'] = value;
                      },
                    ),
                    const SizedBox(
                      height: 21,
                    ),
                    TextField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        labelText: 'File Name',
                        hintText: 'File Name',

                        // prefixIcon: Icon(icon),
                      ),
                      onChanged: (value) {
                        itemCustomMap['file'] = value;
                      },
                    ),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              itemCustom ? null : const Color(0xff1e367c),
                          foregroundColor: Colors.white,
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                              color: Colors.black,
                              width: 0.5,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () async {
                          print(itemCustomMap);
                          itemCustom = !itemCustom;
                          setState(() {});
                        },
                        child: const Text('Custom Data')),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff1e367c),
                          foregroundColor: Colors.white,
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                              color: Colors.black,
                              width: 0.5,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () async {
                          await _captureAndSavePng();
                          setState(() {
                            itemIndex = itemIndex + 1;
                          });
                        },
                        child: const Text('GuardarImagen ')),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _captureAndSavePng() async {
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
