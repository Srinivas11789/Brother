// Imports

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:image_picker/image_picker.dart';

import 'package:wifi/wifi.dart';
import 'package:ping_discover_network/ping_discover_network.dart';
import 'package:multicast_dns/multicast_dns.dart';
import 'package:flutter_blue/flutter_blue.dart';

// Custom Label Definitions
var labelData = {
  "103mmx164mm": "103mmx164mm", 
  "62mmx8m": "62mmx8m",
  'RJ2150:Continuous->58mm': 'G2lhARtpVU8QNzkAhAAAAAAAAAAbaVV3AT8EOgAAOgAAsAEAAAAAAAAAAAAAAKoBAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAANThtbQAAAAAAAAAAAAAAADIuMiIAAAAAAAAAAAAAAAAAAAAAAAAYAAAAAAAAGAAAAAA=',
  'RJ2150:Diecut->100x50': 'G2lhARtpVU8QNzkAhAAAAAAAAAAbaVV3AT8EMmQAMhQAiAEXAwAAAAAAAAAAAAECAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAARGllQ3V0MTAweDUweDUAAAAAAAAAAAAAAAAAAAAAAAAAAEcDAAAEAAAAAAABBAAAAAA=',
};

// Main App trigger
void main() => runApp(MyApp());

// Design a tab viewed interface ( print image, print text )
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appTitle = 'Brother Demo App';
    return MaterialApp(
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              tabs: [
                Tab(icon: Text("Print Text!")),
                Tab(icon: Text("Print Image!")),
              ],
            ),
            title: Text(appTitle),
          ),
          body: TabBarView(
            children: [
              MyPrintFormText(),
              MyPrintFormImage(),
            ],
          ),
        ),
      ),
    );
  }
}

// Initialize all usable variables
// 1. Channel Creation
const platform = const MethodChannel(
    'com.example.brother_demo');
// 2. Selected Printer Choice
String selectedPrinter = "None";
// 3. Available choices list in dropdown
List<String> networkPrinters = ["None"];
// 4. Relation device <--> IP
var discoveredPrinters = new Map();
// 5. Selected Image from Gallery/Camera
File _selectedImage;
// 6. Label sizes selection
List<String> labelsizes = ["None", "103mmx164mm", "62mmx8m", "RJ2150:Diecut->100x50", "RJ2150:Continuous->58mm"];
// 7. Supported models
List<String> supportedModels = ["QL-1110NWB",  "RJ-2150"];
// 8. Selected Choices
var selectedLabel = "None";
var selectedModel = "QL-1110NWB";

// PRINT TEXT FORM
// Create a PrintText widget.
class MyPrintFormText extends StatefulWidget {
  @override
  MyPrintFormTextState createState() {
    return MyPrintFormTextState();
  }
}
// Create a corresponding State class.
// This class holds data related to the form.
class MyPrintFormTextState extends State<MyPrintFormText> {
  // Init variables
  final _formKey = GlobalKey<FormState>();
  final myController = TextEditingController();
  var _canBeClicked = true;
  FindPrinters find = new FindPrinters();

  // Build FORM
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            controller: myController,
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter some text to label!';
              }
              return null;
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: RaisedButton(
              onPressed: () {
                if (_canBeClicked) {
                  _canBeClicked = false;
                  if (_formKey.currentState.validate()) {
                    Scaffold.of(context)
                        .showSnackBar(SnackBar(content: Text('Printing Label!')));
                    _printLabel(myController.text, selectedPrinter);
                  }
                }
              },
              child: Text('Print Label'),
            ),
          ),
          DropdownButtonFormField<String>(
            hint: new Text('Select Discovered Printer'),
            value: selectedPrinter,
            icon: Icon(Icons.arrow_downward),
            iconSize: 24,
            elevation: 16,
            style: TextStyle(
              color: Colors.deepPurple
            ),
            onChanged: (String newValue) {
              setState(() {
                selectedPrinter = newValue;
                if (discoveredPrinters.containsKey(selectedPrinter)) {
                    selectedModel = selectedPrinter.split(" ")[1];
                };
              });
            },
            items: networkPrinters
              .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
          ),
          DropdownButtonFormField<String>(
            hint: new Text('Select Printer Model'),
            value: selectedModel,
            icon: Icon(Icons.arrow_downward),
            iconSize: 24,
            elevation: 16,
            disabledHint: new Text((discoveredPrinters.containsKey(selectedPrinter))?  selectedPrinter.split(" ")[1] : 'Select Printer Model'),
            style: TextStyle(
              color: Colors.amber
            ),
            onChanged: (discoveredPrinters.containsKey(selectedPrinter))? null : (String newValue) {
              setState(() {
                selectedModel= newValue;
              });
            },
            items: supportedModels
              .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
          ),
          DropdownButtonFormField<String>(
            hint: new Text('Select Label Size'),
            value: selectedLabel,
            icon: Icon(Icons.arrow_downward),
            iconSize: 24,
            elevation: 16,
            style: TextStyle(
              color: Colors.deepOrange
            ),
            onChanged: (String newValue) {
              setState(() {
                selectedLabel= newValue;
              });
            },
            items: labelsizes
              .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: RaisedButton(
              onPressed: () {
                find._discoverPrinters();
                find._discoverPrintersWifi();
              },
              child: Text('Discover printers!'),
            ),
          ),
        ],
      ),
    );
  }

  Future<Null> _printLabel(String text, String model) async {
    debugPrint(text);
    debugPrint("Called Function Print!!!!");
    if (discoveredPrinters.containsKey(model)) {
      var modelId = model.split(" ")[1];
      debugPrint(modelId);
      await platform.invokeMethod('printLabel', <String, dynamic>{
          'message': text,
          'printerModel': modelId,
          'ip': discoveredPrinters[model],
          'label': labelData[selectedLabel],
        });
    } else {
      var ip = model.substring(0, model.indexOf('@'));
      debugPrint("Called Function with IP!!!!");
      debugPrint(ip);
      debugPrint(selectedModel);
      await platform.invokeMethod('printLabel', <String, dynamic>{
          'message': text,
          'printerModel': selectedModel,
          'ip': ip,
          'label': labelData[selectedLabel],
        });
    }
    _canBeClicked = true;
  }
}

// PRINT IMAGE FORM
// Create a PrintImagewidget.
class MyPrintFormImage extends StatefulWidget {
  @override
  MyPrintFormImageState createState() {
    return MyPrintFormImageState();
  }
}
// Create a corresponding State class.
// This class holds data related to the form.
class MyPrintFormImageState extends State<MyPrintFormImage> {
  final _formKey = GlobalKey<FormState>();
  final myController = TextEditingController();
  var _canBeClicked = true;
  FindPrinters find = new FindPrinters();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: RaisedButton(
              onPressed: _selectImage,
              child: Text('Pick Image'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: RaisedButton(
              onPressed: () {
                if (_canBeClicked) {
                  _canBeClicked = false;
                  if (_selectedImage != null) {
                    Scaffold.of(context)
                      .showSnackBar(SnackBar(content: Text('Printing Image!')));
                    _printImage(_selectedImage, selectedPrinter);
                  } else {
                    Scaffold.of(context)
                      .showSnackBar(SnackBar(content: Text('Printing Image!')));
                  }
                }
              },
              child: Text('Print Image'),
            ),
          ),
          DropdownButtonFormField<String>(
            hint: new Text('Select Discovered Printer/IP'),
            value: selectedPrinter,
            icon: Icon(Icons.arrow_downward),
            iconSize: 24,
            elevation: 16,
            style: TextStyle(
              color: Colors.deepPurple
            ),
            onChanged: (String newValue) {
              setState(() {
                selectedPrinter = newValue;
              });
            },
            items: networkPrinters
              .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
          ),
          DropdownButtonFormField<String>(
            hint: new Text('Select Printer Model'),
            value: selectedModel,
            icon: Icon(Icons.arrow_downward),
            iconSize: 24,
            elevation: 16,
            disabledHint: new Text((discoveredPrinters.containsKey(selectedPrinter))?  selectedPrinter.split(" ")[1] : 'Select Printer Model'),
            style: TextStyle(
              color: Colors.amber
            ),
            onChanged: (discoveredPrinters.containsKey(selectedPrinter))? null : (String newValue) {
              setState(() {
                selectedModel= newValue;
              });
            },
            items: supportedModels
              .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
          ),
          DropdownButtonFormField<String>(
            hint: new Text('Select Label Size'),
            value: selectedLabel,
            icon: Icon(Icons.arrow_downward),
            iconSize: 24,
            elevation: 16,
            style: TextStyle(
              color: Colors.deepOrange
            ),
            onChanged: (String newValue) {
              setState(() {
                selectedLabel= newValue;
              });
            },
            items: labelsizes
              .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: RaisedButton(
              onPressed: () {
                find._discoverPrinters();
                find._discoverPrintersWifi();
              },
              child: Text('Discover printers!'),
            ),
          ),
        ],
      ),
    );
  }

  Future<Null> _printImage(File selectedFile, String model) async {
    if (discoveredPrinters.containsKey(model)) {
      var modelId = model.split(" ")[1];
      await platform.invokeMethod('printImage', <String, dynamic>{ //dynamic
          'imageFile': selectedFile.path,
          'printerModel': modelId,
          'ip': discoveredPrinters[model],
          'label': labelData[selectedLabel],
        });
    } else {
      var ip = model.substring(0, model.indexOf('@'));
      await platform.invokeMethod('printImage', <String, dynamic>{ //dynamic
          'imageFile': selectedFile.path,
          'printerModel': selectedModel,
          'ip': ip,
          'label': labelData[selectedLabel],
        });
    }
    _canBeClicked = true;
  }
  void _selectImage() async {
    final imageSource = await showDialog<ImageSource>(
        context: context,
        builder: (context) =>
            AlertDialog(
              title: Text("Select the image source"),
              actions: <Widget>[
                MaterialButton(
                  child: Text("Camera"),
                  onPressed: () => Navigator.pop(context, ImageSource.camera),
                ),
                MaterialButton(
                  child: Text("Gallery"),
                  onPressed: () => Navigator.pop(context, ImageSource.gallery),
                )
              ],
            )
    );

    if(imageSource != null) {
      final file = await ImagePicker.pickImage(source: imageSource);
      if(file != null) {
        setState(() => _selectedImage = file);
      }
    }
  }
}

// FIND PRINTER HELPERS
// * For emulator testing, these methods wont work as emulator network is on 10.0.* NAT through host
// * For emulator testing, harcode the IP and model number at method channel calls printLabel or printImage
class FindPrinters {
    // Uses mDNS to discover printers.
    // * Works well on Android. Facing https://github.com/flutter/flutter/issues/42102 on IOS.
    // * For ios leverage Wifi method of printing with 9100 port discovery
    // 1. Discover IP and Model of Printer
    Future<Null> _discoverPrinters() async {
      var reusePort = false;
      if (Platform.isIOS) {
        reusePort = true;
      }
      const String name = '_printer._tcp.local';
      // https://github.com/flutter/flutter/issues/27346#issuecomment-594021847
      var factory = (dynamic host, int port,
          {bool reuseAddress, bool reusePort, int ttl}) {
        return RawDatagramSocket.bind(host, port, reuseAddress: true, reusePort: reusePort, ttl: 255);
      };

      var client = MDnsClient(rawDatagramSocketFactory: factory);
      //final MDnsClient client = MDnsClient();
      await client.start();

      // Get the PTR recod for the service.
      await for (PtrResourceRecord ptr in client
          .lookup<PtrResourceRecord>(ResourceRecordQuery.serverPointer(name))) {
        await for (SrvResourceRecord srv in client.lookup<SrvResourceRecord>(
            ResourceRecordQuery.service(ptr.domainName))) {
          String model =
              ptr.domainName.substring(0, ptr.domainName.indexOf('._printer'));
          print('Dart observatory instance found at '
          '${srv.target}:${srv.port} for "$model".');
          await for (IPAddressResourceRecord ipr in client.lookup(
            ResourceRecordQuery.addressIPv4(srv.target))) {
            debugPrint('Printer found at '
                '${ipr.address} with "$model".');
            model = "(mDNS)"+model;
            discoveredPrinters[model] = ipr.address.host;
            if (!networkPrinters.contains(model)) {
              networkPrinters.add(model);
            }
            debugPrint(discoveredPrinters.toString());
          }
        }
      }
      client.stop();
      debugPrint('Done.');
  }

  // WIFI discovery of devices via Wifi at 9100 port
  // https://en.wikipedia.org/wiki/List_of_printing_protocols
  // 1. Discovers IP but not the model 
  Future<Null> _discoverPrintersWifi() async {
    final String ip = await Wifi.ip;
    final String subnet = ip.substring(0, ip.lastIndexOf('.'));

    final stream = NetworkAnalyzer.discover2(subnet, 9100);
    stream.listen((NetworkAddress addr) {
      if (addr.exists && !networkPrinters.contains(addr.ip+"@9100")) {
        networkPrinters.add(addr.ip+"@9100");
      }
    });
    debugPrint(networkPrinters.toString());
    debugPrint(ip);
    debugPrint(subnet);
  }

  // TODO: Find model from the IP --> Leverage SNMP for the below OID.
  // * No SNMP lib for dart but we can pull this off via snmp socket for SNMP GET ( IN PROGRESS )
  // Mimic String model = finder.getMibValue(ipAddress, "1.3.6.1.2.1.25.3.2.1.3.1"); from sdk
  Future<Null> _getPrinterModel(String ipaddress) async {
    final ipObj = InternetAddress(ipaddress);
    RawDatagramSocket.bind(ipObj, 4444).then((RawDatagramSocket socket){
    print('Sending from ${socket.address.address}:${socket.port}');
    socket.send("".codeUnits, ipObj, 161);
    socket.listen((RawSocketEvent e){
      Datagram d = socket.receive();
      if (d == null) return;
      String model = new String.fromCharCodes(d.data);
      debugPrint(model);
    });
  });
  }

  // Discovery of devices via Bluetooth
  // Ref: https://pub.dev/packages/flutter_blue
  Future<Null> _discoverPrintersBlt() async {
    FlutterBlue flutterBlue = FlutterBlue.instance;
    flutterBlue.startScan(timeout: Duration(seconds: 5));
    var subscription = flutterBlue.scanResults.listen((results) {
      for (ScanResult r in results) {
          networkPrinters.add(r.device.name);
          print('${r.device.name} found! rssi: ${r.rssi}');
      }
    });
    flutterBlue.stopScan();
    // Add to network printers
    debugPrint(networkPrinters.toString());
  }
}
