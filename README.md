## Brother Printer Demo App
- Cross Platform App (Android/IOS) for Brother Printers using Flutter

### Goal
* Easy onboarding of any developer into app development with Brother printers.
* Minimize the foundation building time and speed up converting ideas into apps for Brother printers. 

### Summary
* **What does this accomplish?**
  - A starter to develop Brother printer apps using Flutter

* **What are the supported platforms?**
  - IOS
  - Android  

* **What languages are used?**
  - IOS ( Swift )
  - Android ( Kotlin )
  - Flutter ( Dart )
  
* **Functionalities?**
  - **Print Text:**
  > Takes text input to print out a label
  - **Print Image:**
  > Takes camera/gallery selected images to print out a label
  - **Discover Printer**
  ```
    1) `mDNS` --> using multicast dns to detect printers in local networks and their models ( Fully works on Android )

    2) `Wifi Port Scans` --> scanning for print protocols ports like ( Just port 9100 or IPP, LPR ). 
      - Detecting models using this method can be achieved through SNMP. ( InProgress )
  ```
* **Technique used?**
  - `Hybrid Method` of leveraging existing SDK stuff Brother has built for the respective platforms and driving them using Flutter ( Kind of like a FrontEnd ). That way we avoid rewriting the sdk in Flutter and reuse them as Native code!
  - `Method Channels` in Flutter to call into the existing Brother SDK methods in their own platform
  - `Background:` Brother already has SDKs for IOS (ObjC) and Android (Java) that work pretty well in respective platforms. 
  
* **Whats next?**
  - Now that we have calls that work with native sdks for printing stuff. We can build our APP idea/functionality with Flutter that would be cross platform.

### Getting Started
This is a demo project that you could leverage to start building on top of. Some of the code has been intentionally kept simple to easily understand the flow.

### Test the App

```
* Download and install Flutter
  - for IOS, you would need xCode to sign and run the application 
  - for Android, AndroidStudio helps in debugging faster
* Clone the repository, check with doctor and run
  - flutter doctor -v 
  - flutter run 
```
  
### Caveat or Things to Look out for

* `Real devices VS Emulators`
  - The emulators network is not exposed directly to LAN so the `printer detection` wont work. In that case hardocde the methodChannel calls with the IP Address of the printer and corresponding model number + label size.

### Flow Diagram



### Demo
[]()

### Finding the Printer ( Discover printer logic )
* Bonjour spec
```
_printer._tcp.local.        Port 515
_ipp._tcp.local.            Port 631
_pdl-datastream._tcp.local. Port 9100
```

### Credits
* Built as a part of Brother Hackathon 2020 - Thanks to all the peers!
  - Rob Payne's introduction to Flutter
* Thanks to the authors of all the references that helped me!

### References

* Design/Methods
  - https://raw.githubusercontent.com/flutter/flutter/master/.gitignore
  - https://flutter.dev/docs/development/platform-integration/platform-channels
  - https://stackoverflow.com/questions/59669933/how-to-turn-asset-image-into-bitmap-in-flutter-dart
  - https://medium.com/john-lewis-software-engineering/adding-a-third-party-framework-inside-a-first-party-framework-in-xcode-3ba58cfd08da
  - https://medium.com/47billion/creating-a-bridge-in-flutter-between-dart-and-native-code-in-java-or-objectivec-5f80fd0cd713
  - https://medium.com/@pahlevikun/bridging-between-dart-and-native-code-with-flutter-channel-for-communicate-each-other-7c736929ee42
  - https://blog.usejournal.com/integrating-native-third-party-sdk-in-flutter-8aab03afa9da
  - https://blog.solutelabs.com/integrating-third-party-native-sdks-in-flutter-df418829dcf7
  - https://flutter.dev/docs/development/platform-integration/platform-channels
  - https://github.com/rahimkhalid/FlutterWithSurveryMonkey
  - https://fluttertutorial.in/method-channel-in-flutter/
  - https://github.com/RafaO/FlutterNativeCommunication
  - https://proandroiddev.com/communication-between-flutter-and-native-modules-9b52c6a72dd2
  - https://github.com/anilgsharma900/MethodChannelDemo
  - https://medium.com/@Anil_Sharma/methodchannel-in-flutter-727d3823d6ac
  - https://stablekernel.com/article/flutter-platform-channels-quick-start/
  - https://stackoverflow.com/questions/53105715/what-is-the-substitute-for-deprecated-staticlayout
* Network
  - https://pub.dev/packages/wifi#-installing-tab-
  - https://pub.dev/packages/ping_discover_network#-installing-tab-
  - https://blog.hyperiongray.com/multicast-dns-service-discovery/
  - https://pub.dev/documentation/multicast_dns/latest/
  - https://developer.apple.com/bonjour/printing-specification/bonjourprinting-1.2.1.pdf
  - http://jamesslocum.com/post/77759061182
* UI
  - https://stackoverflow.com/questions/58897270/adding-icon-to-left-of-dropdownbutton-expanded-in-flutter
  - https://flutter.dev/docs/cookbook/forms/validation
  - https://medium.com/@afegbua/flutter-thursday-08-multi-level-dependent-dropdown-d965c08d2748
  - https://stackoverflow.com/questions/58363597/dropdownbutton-in-flutter-not-changing-values-to-the-selected-value
  - https://github.com/invoiceninja/flutter-client/blob/master/samples/form_keys.dart
  - https://hillel.dev/2018/06/12/flutter-complex-forms-with-multiple-tabs-and-relationships/
  - https://stackoverflow.com/questions/56410110/flutter-dropdownbutton-show-label-when-option-is-selected
  - https://api.flutter.dev/flutter/material/DropdownButtonFormField/DropdownButtonFormField.html
  - https://medium.com/flutterpub/sample-form-part-2-flutter-c19e9f37ac41
  - https://medium.com/@nitishk72/form-validation-in-flutter-d762fbc9212c
* Images
  - https://pub.dev/packages/image_picker
  - https://theswiftdev.com/picking-images-with-uiimagepickercontroller-in-swift-5/
  - https://stackoverflow.com/questions/5151744/upload-picture-to-emulator-gallery
  - https://stackoverflow.com/questions/59669933/how-to-turn-asset-image-into-bitmap-in-flutter-dart
  - https://stackoverflow.com/questions/49835623/how-to-load-images-with-image-file
  - https://dev.to/pedromassango/let-s-pick-some-images-with-flutter-575b
  - https://developer.apple.com/library/archive/documentation/2DDrawing/Conceptual/DrawingPrintingiOS/HandlingImages/Images.html
  - https://gist.github.com/superpeteblaze/14885c5e2c8a5ccfbddb
  - https://www.hackingwithswift.com/example-code/core-graphics/how-to-draw-a-text-string-using-core-graphics
  - https://stackoverflow.com/questions/28906914/how-do-i-add-text-to-an-image-in-ios-swift
  - https://teamtreehouse.com/community/how-to-rotate-images-to-the-correct-orientation-portrait-by-editing-the-exif-data-once-photo-has-been-taken
  - https://stackoverflow.com/questions/34532502/resizing-portrait-bitmap-to-landscape-dimensions-in-android
  - https://stackoverflow.com/questions/9015372/how-to-rotate-a-bitmap-90-degrees
  - https://android--code.blogspot.com/2015/11/android-how-to-rotate-canvas.html
  - https://www.skoumal.com/en/android-drawing-multiline-text-on-bitmap/
  - https://www.skoumal.com/en/android-guide-draw-text-over-bitmap/
  - https://medium.com/swlh/fun-with-text-to-image-in-android-c70046b76682
  - https://android.okhelp.cz/create-bitmap-and-draw-text-into-bitmap-android-example/
  - https://discuss.kotlinlang.org/t/using-a-bitmap-inside-a-new-android-project/14714
* Random Helpers
  - https://github.com/CocoaPods/CocoaPods/issues/8377    