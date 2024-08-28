import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:ad_hoc_ident/ad_hoc_ident.dart';
import 'package:ad_hoc_ident_nfc/ad_hoc_ident_nfc.dart';
import 'package:ad_hoc_ident_nfc_detect_emv/ad_hoc_ident_nfc_detect_emv.dart';
import 'package:ad_hoc_ident_nfc_scanner_nfc_manager/ad_hoc_ident_nfc_scanner_nfc_manager.dart';
import 'package:ad_hoc_ident_ocr/ad_hoc_ident_ocr.dart';
import 'package:ad_hoc_ident_ocr_camerawesome/ad_hoc_ident_ocr_camerawesome.dart';
import 'package:ad_hoc_ident_ocr_extract_google/ad_hoc_ident_ocr_extract_google.dart';
import 'package:ad_hoc_ident_ocr_parse_mrz/ad_hoc_ident_ocr_parse_mrz.dart';
import 'package:ad_hoc_ident_util_crypto/ad_hoc_ident_util_crypto.dart';
import 'package:ad_hoc_ident_util_flutter/ad_hoc_ident_util_flutter.dart';
import 'package:ad_hoc_ident_util_readable_pseudonym/ad_hoc_ident_util_readable_pseudonym.dart';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import 'ad_hoc_identity_display.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final MemoryPseudonymStorage _storage = PseudonymStorage.memory();

  late final NfcScanner _nfcScanner;
  late final AdHocIdentityScanner<OcrImage> _ocrScanner;
  late final OcrTextExtractor _extractor;
  late final StreamController<OcrImage> _cameraStreamController;

  Stream<AdHocIdentity?>? _identityStream;
  bool _showCamera = true;

  void _toggleCamera() => setState(() {
        _showCamera = !_showCamera;
      });

  @override
  void initState() {
    final securePepper = _initPepper();
    final encrypter = WordPseudonymEncrypter(
            innerEncrypter: CryptoAdHocIdentityEncrypter.sha512,
            storage: _storage)
        // in production code you might want to add a salt and obfuscate
        // the type
        // .secureType()
        // .withSalt((identity) => 'someSecurelyCreatedOrFetchedSalt')
        .withPepper(securePepper);

    final nfcDetector = AdHocIdentityDetector.fromList([
      // keep the uid detector first,
      // as it restarts the nfc adapter,
      // causing all adapters before it to be evaluated again.
      NfcDetectorUid(restartTimeout: const Duration(seconds: 1)),
      NfcDetectorEmv(),
    ]);
    _nfcScanner = _initNfcManagerScanner(nfcDetector, encrypter);
    // _nfcScanner = _initNfcKitScanner(nfcDetector, encrypter);

    // With this implementation, the app needs to be restarted,
    // if nfc is unavailable during startup.
    // In a productive environment you might want to re-poll the nfc state
    // until it becomes available
    _nfcScanner.isAvailable().then((available) {
      if (available) {
        _nfcScanner.start();
      }
    });

    _cameraStreamController = StreamController.broadcast();

    // Wrapping the google extractor in a future is simply to allow easier
    // switching between the engines.
    Future.value(GoogleOcrTextExtractor()).then(
      // TesseractOcrTextExtractor.fromFile().then(
      (extractor) {
        _extractor = extractor;
        _ocrScanner = AdHocIdentityScanner(
          inputStream: _cameraStreamController.stream,
          // use a background detector to offload ocr to another isolate
          detector: BackgroundIdentityDetector(
            OcrIdentityDetector(
              extractor: extractor,
              parser: MrzTextIdentityParser(),
            ),
          ),
          debounce: true,
          encrypter: encrypter,
        );

        final stream = StreamGroup.merge([
          _nfcScanner.stream,
          _ocrScanner.stream.whereNotNull(),
        ]).distinct().shareValue().asBroadcastStream();

        if (mounted) {
          setState(() {
            _identityStream = stream;
          });
        }
      },
    );

    super.initState();
  }

  NfcScanner _initNfcManagerScanner(AdHocIdentityDetector<NfcTag> detector,
      AdHocIdentityEncrypter encrypter) {
    final unhandledScanner = NfcManagerNfcScanner(
        detector: detector,
        preferredTagTypes: [
          PlatformTagType.isoDep, // prefer isoDep for emv capabilities
        ],
        encrypter: encrypter);
    return unhandledScanner.handle<FirstScanException>(
        FirstScanException.createDefaultHandler(unhandledScanner));
  }

  // NfcScanner _initNfcKitScanner(AdHocIdentityDetector<NfcTag> detector,
  //     AdHocIdentityEncrypter encrypter) {
  //   final unhandledScanner = NfcKitNfcScanner.repeatPolling(
  //       detector: detector,
  //       idleDuration: const Duration(milliseconds: 100),
  //       encrypter: encrypter);
  //   return unhandledScanner.handle<FirstScanException>(
  //     (error, stackTrace) {
  //       //ignore
  //     },
  //   );
  // }

  String _initPepper() {
    // in a productive environment,
    // the pepper should be managed in secure storage or an external API
    final rng = Random.secure();
    final List<int> securePepperBytes = [];
    for (var i = 0; i < 32; i++) {
      final byte = rng.nextInt(256);
      securePepperBytes.add(byte);
    }
    return base64Encode(securePepperBytes);
  }

  @override
  void dispose() {
    _cameraStreamController.close();
    _nfcScanner.stop();
    _extractor.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const waitingMessage = 'Please scan a NFC tag or passport. '
        'Disable the camera with the top right button before scanning '
        'a NFC tag. Using NFC while the camera is active could cause '
        'crashes on some devices.';
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Ad hoc ident'),
          actions: [
            Padding(
              padding: const EdgeInsets.all(5),
              child: _RestartButton(
                restart: () async {
                  final available = await _nfcScanner.isAvailable();
                  if (available) {
                    _nfcScanner.restart();
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(5),
              child: IconButton(
                onPressed: _toggleCamera,
                icon: Icon(_showCamera ? Icons.videocam_off : Icons.videocam),
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(5),
          child: Flex(
            direction: MediaQuery.orientationOf(context) == Orientation.portrait
                ? Axis.vertical
                : Axis.horizontal,
            children: [
              Expanded(
                flex: 2,
                child: Card(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    side: BorderSide(
                      color: Colors.black,
                      width: 2,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: AspectRatio(
                    aspectRatio: 4 / 3,
                    child: _showCamera
                        ? CamerawesomeAdapter(
                            onImage: _cameraStreamController.add)
                        // ? CameraView(
                        //     onImage: _cameraStreamController.add,
                        //     imageFormatGroupName: 'jpeg', // 'nv21',
                        //   )
                        : TextButton.icon(
                            onPressed: _toggleCamera,
                            label: const Text('Enable camera'),
                            icon: const Icon(Icons.videocam),
                          ),
                  ),
                ),
              ),
              const SizedBox.square(
                dimension: 10,
              ),
              Flexible(
                flex: 1,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: _identityStream != null
                        ? AdHocIdentityDisplay.fromStream(
                            stream: _identityStream!,
                            nullMessage: 'No identity detected.',
                            waitingMessage: waitingMessage,
                            errorBuilder: (error, _) => Text(error.toString()),
                          )
                        : const Text(waitingMessage),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RestartButton extends StatelessWidget {
  final Future<void> Function() restart;

  const _RestartButton({required this.restart});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Trying to reconnect nfc...'),
        ));
        await restart();
      },
      icon: const Icon(Icons.nfc),
    );
  }
}
