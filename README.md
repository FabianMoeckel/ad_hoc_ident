Provides a framework to extract identifiers from NFC tags and MRZ documents. 

> Some features are currently only supported on Android.

> Using NFC and the camera at the same time can lead to crashes. 
> Disable the camera before presenting a NFC tag.

## Features
The package consists of three domain packages. Each is provided with some implementation packages.
* **Main domain:** [ad\_hoc\_ident](https://pub.dev/packages/ad_hoc_ident)
    * **Hashing algorithms:** [ad\_hoc\_ident\_util\_crypto](https://pub.dev/packages/ad_hoc_ident_util_crypto)
    * **Human readable pseudonym generation:** [ad\_hoc\_ident\_util\_readable\_pseudonym](https://pub.dev/packages/ad_hoc_ident_util_readable_pseudonym)
    * **Background isolates:** [ad\_hoc\_ident\_util\_flutter](https://pub.dev/packages/ad_hoc_ident_util_flutter)
* **NFC Domain:** [ad\_hoc\_ident\_nfc](https://pub.dev/packages/ad_hoc_ident_nfc)
    * **Stream based input:** [ad\_hoc\_ident\_nfc\_nfc\_manager](https://pub.dev/packages/ad_hoc_ident_nfc_nfc_manager)
    * **Polling based input:** [ad\_hoc\_ident\_nfc\_flutter\_nfc\_kit](https://pub.dev/packages/ad_hoc_ident_nfc_flutter_nfc_kit)
    * **EMV card number detection:** [ad\_hoc\_ident\_nfc\_detect\_emv](https://pub.dev/packages/ad_hoc_ident_nfc_detect_emv)
* **OCR Domain:** [ad\_hoc\_ident\_ocr](https://pub.dev/packages/ad_hoc_ident_ocr)
    * **Basic [camera](https://pub.dev/packages/camera) input:** [ad\_hoc\_ident\_ocr\_camera](https://pub.dev/packages/ad_hoc_ident_ocr_camera)
    * **Camera input based on the [camerawesome](https://pub.dev/packages/camerawesome) package:** [ad\_hoc\_ident\_ocr\_camerawesome](https://pub.dev/packages/ad_hoc_ident_ocr_camerawesome)
    * **Text extraction based on [google\_ml\_kit](https://pub.dev/packages/google_mlkit_text_recognition):** [ad\_hoc\_ident\_ocr\_extract\_google](https://pub.dev/packages/ad_hoc_ident_ocr_extract_google)
    * **Text extraction based on [flutter\_vision](https://pub.dev/packages/flutter_vision) (Tesseract):** [ad\_hoc\_ident\_ocr\_extract\_tesseract](https://pub.dev/packages/ad_hoc_ident_ocr_extract_tesseract)
    * **MRZ document type and number detection based on [mrz\_parser](https://pub.dev/packages/mrz_parser):** [ad\_hoc\_ident\_ocr\_parse\_mrz](https://pub.dev/packages/ad_hoc_ident_ocr_parse_mrz)

## Getting started

Add the main domain package to your app's pubspec.yaml file and 
add the packages of the features you require for your app.

## Usage

Make yourself familiar with the example app, 
as it provides a good overview on how to combine the different packages. 
Otherwise pick and match the features that suite you. 
All features implemented out of the box have their interfaces defined in the respective 
domain package, so you can easily create and integrate your own implementations.

## Additional information

If you use this package and implement your own features or extend the existing ones, 
consider creating a pull request. This project was created for university, but if it is useful 
to other developers I might consider supporting further development.

Please be aware that reading MRZ documents or NFC tags of other persons might be restricted by 
local privacy laws.
