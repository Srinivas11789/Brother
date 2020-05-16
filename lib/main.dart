// Imports

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:wifi/wifi.dart';
import 'package:ping_discover_network/ping_discover_network.dart';
import 'package:multicast_dns/multicast_dns.dart';

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
    return MaterialApp(
      //title: 'Bromodoro Focus! ( bro + pomodoro )',
      home: FirstPage(),
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
// 9. Track validation of final start of focus
var _canBeClicked = true;
// 10. Tasks List
//List<String> _tasksList2 = ["slot1", "slot2", "slot3", "slot4", "slot5", "slot6", "slot7", "slot8", "slot9", "slot10", "slot11", "slot12"];
List<String> _tasksList = [];
//List<TextEditingController> _tasksList;
// 11. Duration
var selectedDuration = 0;
List<int> durations = [0, 1, 2, 3, 4, 5];

// PRINT TEXT FORM
// Create a PrintText widget.
class FirstPage extends StatefulWidget {
  @override
  InitPage createState() {
    return InitPage();
  }
}

// Create a corresponding State class.
// This class holds data related to the form.
class InitPage extends State<FirstPage> {

  // Init variables
  final _formKey = GlobalKey<FormState>();

  // Build FORM
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text("Bromodoro Focus!"),
      ),
    body: new Column(
      mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('Select Pomodoro Duration!',  
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontWeight: FontWeight.bold),
          ),
          DropdownButtonFormField<int>(
            hint: new Text('Pomodoro Duration!'),
            value: selectedDuration,
            icon: Icon(Icons.arrow_downward),
            iconSize: 24,
            elevation: 16,
            style: TextStyle(
              color: Colors.red
            ),
            onChanged: (int newValue) {
              setState(() {
                 selectedDuration = newValue;
              });
            },
            items: durations
              .map<DropdownMenuItem<int>>((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text(value.toString() + " Hours"),
                );
              }).toList(),
          ),
          RaisedButton(
            child: Text('Add Tasks!'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TaskSetup()),
              );
            },
          ),
          RaisedButton(
            child: Text('Set Printer!'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PrintSetup()),
              );
            },
          ),
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: RaisedButton(
                onPressed: () {
                  if (_canBeClicked) {
                    _canBeClicked = false;
                    //if (_formKey.currentState.validate()) {
                      _printLabel(_tasksList, selectedPrinter);
                    //}
                  }
                Scaffold.of(context)
                  .showSnackBar(SnackBar(content: Text('Focus Countdown Started!')));
                },
                child: Text('Start Focusing!!!!'),
              ),
            ),
        ],
      ),
    );
  }

  Future<Null> _printLabel(List<String> text, String model) async {
    debugPrint(text.toString());
    debugPrint("Called Function Print!!!!");
    if (discoveredPrinters.containsKey(model)) {
      var modelId = model.split(" ")[1];
      debugPrint(modelId);
      await platform.invokeMethod('printLabel', <String, dynamic>{
          'message': text.toString(),
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
          'message': text.toString(),
          'printerModel': selectedModel,
          'ip': ip,
          'label': labelData[selectedLabel],
        });
    }
    _canBeClicked = true;
  }
}

class TaskSetup extends StatefulWidget {
  @override
  TasksList createState() {
    return TasksList();
  }
}

class TasksList extends State<TaskSetup> {

  List<TextEditingController> tasksList= List.generate(selectedDuration*60~/25+1, (index) {
    if (_tasksList.length > index) {
      return TextEditingController(text: _tasksList[index]);
    }
    return TextEditingController(text: "Task " + index.toString());
  });

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text("Pomodoro Tasks List"),
      ),
      body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
        //Padding(
        //padding: EdgeInsets.all(10),
        //child:
        Expanded(
        child: ListView.builder(  // ListView with 100 TextFields as children
          itemCount: tasksList.length,
          itemBuilder: (context, index) {
            return TextField(
              controller: tasksList[index],
            );
           },
         ),
        //),
        ),
        RaisedButton(
            onPressed: () {
              for (var i = 0; i < selectedDuration*60~/25+1; i++) {
                _tasksList.add(tasksList[i].text);
                tasksList[i].dispose();
              }
              Navigator.pop(context);
            },
            child: Text('Done!'),
         ),
        ]
      )
    );
   }
}

class PrintSetup extends StatefulWidget {
  @override
  PrinterSetting createState() {
    return PrinterSetting();
  }
}

class PrinterSetting extends State<PrintSetup> {
  
  final _printerForm = GlobalKey<FormState>();
  FindPrinters find = new FindPrinters();
  var _canBeClicked = true;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: const Text('Printer Settings!'),
      ),
      body: new Column(
      mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
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
        RaisedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Done!'),
        ),
        ]
      ),
    );
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

  // Find model from the IP --> Leverage SNMP for the below OID.
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
}
