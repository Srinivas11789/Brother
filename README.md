## Brother Printer Demo App
- Cross Platform App (Android/IOS) for Brother Printers using Flutter

### Goal
* Easy onboarding of any developer into app development with Brother printers.
* Minimize the foundation building time and speed up converting ideas into apps for Brother printers. 

### Summary
* **What does this accomplish?**
  - A starter to develop Brother printer apps using Flutter ( One of the ways! )

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
This is a demo project that you could leverage to start building on top of. Some of the code has been intentionally kept simple to easily understand the flow and without proper error handling.

* Test the App

```
* Download and install Flutter
  - for IOS, you would need xCode to sign and run the application 
  - for Android, AndroidStudio helps in debugging faster
* Clone the repository, check with doctor and run
  - flutter doctor -v 
  - flutter run 
```

* Steps to keep things going
> As there are not a lot of err handling done ( inprogress to make it better! ), following this should keep everything good.
```
1. Use discover printers to discover brother printers in the network. Select the corresponding printer from the dropdown. ( dropdown might need a nudge to update )
2. Select the printer and label size you have installed
3. Select image from camera/gallery or text to then print
```

### Flow Diagram
![flow](https://github.com/Srinivas11789/Brother/blob/master/assets/flow.png)

### Expanding Logic to Include All the Printer Models
* mDNS allows you to discover the IPaddress and the MODEL of the printer. Currently this would happen and discover as {modelId: Ipaddress}
* On the Android side, I have a map that relates the printerId to the ENUM value of printer model used inside the SDK. This map can be updated with your model ENUM or all the models to make it work with any models

* This currently is supported only on Android as there is a mDNS IOS issue that needs to be resolved ( ref: https://github.com/flutter/flutter/issues/42102 )

* `To add new printer model?` If your printer is discovered via mDNS and shows in the dropdown ( should happen! ) --> Just update the map of printers in android side with the model and things should work!. Let me know otherwise, happy to debug...
* Current workaround for IOS: 
  - For IOS, I have used WIFI discovery for port 9100 but hardcoded the modelId to the one I use ( QL1110W ). I have an extra method to use SNMP to fetch this which is yet to be completed!
  - Update the modelId to the one you have to make it work with IOS

* Similar steps required for Label sizes

### App Screens 

<img src=https://github.com/Srinivas11789/Brother/blob/master/assets/android1.jpg height="625" width="350" hspace="20"/>  <img src=https://github.com/Srinivas11789/Brother/blob/master/assets/android2.jpg height="625" width="350"/>
  
### Caveat or Things to Look out for

* `Real devices VS Emulators`
  - The emulators network is not exposed directly to LAN so the `printer detection` wont work. In that case hardcode the methodChannel calls with the IP Address of the printer and corresponding model number + label size. 

* Printer must be connected to the same wireless network the device is ( real device )
  
  
  
  - So far the case with Brother QL-1110NWB
  - If printer is not wirelessly connected, it may still show up in the app, but the connection to print will always fail
  - Steps to get connected:
  - 1. Power on printer (wait for solid green light)
    
    2. Download Brother Wireless Wizard [here](https://support.brother.com/g/b/midlink_product.aspx?c=ca&lang=en&content=dl&site=pc&orgc=ca&orglang=en&targetpage=17&pcatid=37)
    
    3. Set up wireless using the wizard steps. If wireless setup fails using the WPS button, wait until it gives option to set up using USB
    
    4. Once printer is connected to network, make sure device is on the same network and you're good to go!

* Running flutter on IOS devices ( real device )
  
  - Xcode might be needed to run the app on IOS to take care of signing the app and handle while screen is locked. ( Product > Run )
  - Debugging a few known Xcode errors:
    1. If Flutter run gives a build error with Xcode migration, complete the steps [here](https://flutter.dev/docs/development/ios-project-migration) and it should work after that
    
    2. - Run(Flutter IDE): flutter clean
       
       - Run (Xcode): Product -- > Clean Build Folder

* IOS launch failure on real device with Pod Errors
  
  - Clean up the Pods folder (https://github.com/CocoaPods/CocoaPods/issues/8377)
  - flutter clean & flutter run
  - pod install
  - You also might need to sign the app and trust the signature on your IOS device. 

### Demo
<p align="center">
  <img src=https://github.com/Srinivas11789/Brother/blob/master/assets/demo.gif />
</p>

### Finding the Printer ( Discover printer logic )
> --> Method 1
* I was amazed looking at MAC having ability to detect all printer  types --> dug in to the [BonjourSpec](https://developer.apple.com/bonjour/printing-specification/bonjourprinting-1.2.1.pdf). Specifically this,
```
_printer._tcp.local.        Port 515
_ipp._tcp.local.            Port 631
_pdl-datastream._tcp.local. Port 9100
```
* Using [mDNS](https://en.wikipedia.org/wiki/Multicast_DNS) it is possible to resolve services within small networks that is WIFI. We could retrieve the model and ip address using the multicast_dns package in Flutter. ( This works in Android )
* As said before in IOS the mDNS method needs a little bit of work or fix to have it working.

> --> Method 2
* We could scan for network ports that are open directly. So looking for 9100 returns ip address of the printer.
* To get the model we could either reverse resolve the ipaddress :bulb:
* Or, use SNMP get to query for specific OID.
* As of now, the modelID discovery is in progress....

### Custom Label Logic with RJ Printers ( Specifically RJ 2150 and extendable.... )
* `Implemented`
  - Introduced a new map for labels to hold the exact label data to be fed to the printer
  - For custom labels, we use base64 encoded version of the label data 
    - `Pros:` This allows us to avoid `.bin` files + file operations + downloading or moving bin files. Instead we use the base64 encoded label data directly.
    - To add new label data --> Use printer setting tool available for windows --> `cat <label_name>.bin | base64` --> add to the map
* `Other Logic Considered and also be better`
  - Use the `<label_name>.bin` in assets at native code ( android/ ios) - Android part of this logic is already done but not used
  - Use the `<label_name>.bin` in assets at dart side and share to native platform --> https://flutter.dev/docs/development/ui/assets-and-images 

### ToDos/Upgrades
* Some of the ops functions like stringToBitmap, createLabelRJ can be moved to Dart side to decrease native code.

### Credits
* Built as a part of Brother Hackathon 2020 - Thanks to all the peers and Brother Inc!
  Specially,
  - Rob Payne's introduction to Flutter
  - Linus for oranizing everything!
* Thanks to the authors of all the references that helped me!

### Log

* April 25
  - Research method channels and a minimal app flow working between Flutter --> IOS, Android
  - Write wrappers for Brother SDK in android and ios to call into.
* April 26
  - Add the printText functionality
  - Test, test, test ( Emulators + Real devices )
  - Start with printImages
* May 2
  - Printer discovery research and add logic
  - Make multiple ways of making this works and test, test, test
  - Solve flutter issues...
* May 3
  - Work on flutter UI to have more options
  - Clean up, document and :rocket:


> This app is not complete so please feel free to contribute!


### References
```
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
```
