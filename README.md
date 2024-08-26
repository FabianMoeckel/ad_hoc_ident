Provides a framework to extract identifiers from NFC tags and MRZ documents. 

> Some features are currently only supported on Android.

> Using NFC and the camera at the same time can lead to crashes. 
> Disable the camera before presenting a NFC tag.

## Features
The package consists of three domain packages. Each is provided with some implementation packages.
* **Main domain:** *ad\_hoc\_identity*
    * **Hashing algorithms:** *ad\_hoc\_identity\_crypto*
    * **Human readable pseudonym generation:** *ad\_hoc\_identity\_readable\_pseudonym*
    * **Background isolates:** *ad\_hoc\_identity\_flutter*
* **NFC Domain:** *ad\_hoc\_identity\_nfc*
    * **Stream based input:** *ad\_hoc\_identity\_nfc\_nfc\_manager*
    * **Polling based input:** *ad\_hoc\_identity\_nfc\_flutter\_nfc\_kit*
    * **EMV card number detection:** *ad\_hoc\_identity\_nfc\_detect\_emv*
* **OCR Domain:** *ad\_hoc\_identity\_ocr*
    * **Basic *camera* input:** *ad\_hoc\_identity\_ocr\_camera*
    * **Input based on the *camerawesome* package:** *ad\_hoc\_identity\_ocr\_camerawesome*
    * **Text extraction based on *google_ml_kit*:** *ad\_hoc\_identity\_ocr\_extract\_google*
    * **Text extraction based on *flutter_vision*:** *ad\_hoc\_identity\_ocr\_extract\_tesseract*
    * **MRZ document type and number detection:** *ad\_hoc\_identity\_ocr\_parse\_mrz*

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
