import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller = self.window.rootViewController as! FlutterViewController
        if #available(iOS 10.0, *) {
            linkNativeCode(controller: controller)
        } else {
            // Fallback on earlier versions
        }
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

extension AppDelegate {
    
    @available(iOS 10.0, *)
    func linkNativeCode(controller: FlutterViewController) {
        setupMethodChannelForBrotherSdk(controller: controller)
    }
    
    // First Activity to control method channel calls
    @available(iOS 10.0, *)
    private func setupMethodChannelForBrotherSdk(controller: FlutterViewController) {
        
        let brotherSdkChannel = FlutterMethodChannel.init(name: "com.example.brother_demo", binaryMessenger: controller as! FlutterBinaryMessenger)
        
        brotherSdkChannel.setMethodCallHandler { (call, result) in
            if call.method == "printLabel" {
                let args = call.arguments as? [String: Any];
                let text =  args?["message"] as? String;
                let printerModel = args?["printerModel"] as? String;
                let ip = args?["ip"] as? String;
                let label = args?["label"] as? String;
                self.printLabel(message: text!, model: printerModel!, ip: ip!, label:label!)
                result("Done");
            } else if call.method == "printImage" {
                let args = call.arguments as? [String: Any];
                let location =  args?["imageFile"] as? String;
                let printerModel = args?["printerModel"] as? String;
                let ip = args?["ip"] as? String;
                let label = args?["label"] as? String;
                self.printImage(location: location!, model: printerModel!, ip: ip!, label: label!)
                result("Done");
            } else {
                result(FlutterMethodNotImplemented);
            }
        }
    }
    
    
    // Convert text to bitmap image
    @available(iOS 10.0, *)
    private func stringToBitMap(message: String) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        let img = renderer.image { ctx in
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center

            let attrs = [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Thin", size: 36)!, NSAttributedString.Key.paragraphStyle: paragraphStyle]

            message.draw(with: CGRect(x: 32, y: 32, width: 448, height: 448), options: .usesLineFragmentOrigin, attributes: attrs, context: nil)
        }
        return img
    }

    // Create custom label file from the label data
    @available(iOS 10.0, *)
    private func createRJLabel(labelData: String) -> String {
      let encodedLabelData = labelData.padding(toLength: ((labelData.count+3)/4)*4, withPad: "=", startingAt: 0)
      //https://stackoverflow.com/questions/36364324/swift-base64-decoding-returns-nil
      var labelDataDecoded: Data = "Dummy ".data(using: .utf8)!
      let data = Data(base64Encoded: encodedLabelData, options: .ignoreUnknownCharacters)
      if let data = data {
        labelDataDecoded  =  data
      }
      print(labelDataDecoded)
      //https://stackoverflow.com/questions/24181699/how-to-check-if-a-file-exists-in-the-documents-directory-in-swift
      if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
          let fileURL = dir.appendingPathComponent(labelData+".bin")
          //if FileManager.default.fileExists(atPath: fileURL.path) {
          //  return fileURL.path
          //}
          do {
            try labelDataDecoded.write(to: fileURL)
          } catch {
            print("Error info: \(error)")
            return ""
          }
          //print(fileURL.path)
          return fileURL.path
      }
      return ""
    }
    
    // Print Label
    @available(iOS 10.0, *)
    private func printLabel(message: String, model: String, ip: String, label: String) {
        // Convert text into image
        let image = stringToBitMap(message: message)
        print("get image")
        
        // Specify printer
        let printer = BRPtouchPrinter(printerName: model, interface: CONNECTION_TYPE.WLAN)!
        printer.setIPAddress(ip)
        print("set printer")

        // Print Settings
        let settings = BRPtouchPrintInfo()
        if model.contains("RJ") {
            settings.strPaperName = "CUSTOM"
            printer.setCustomPaperFile(createRJLabel(labelData: label))
        } else {
            settings.strPaperName = label
        }
        settings.nPrintMode = PRINT_FIT_TO_PAGE
        settings.nAutoCutFlag = OPTION_AUTOCUT
        printer.setPrintInfo(settings)
        print("set options")
        
        guard printer.isPrinterReady() else {
            print("*** Printer is not Ready ***")
            return
        }

        // Connect, then print
        if printer.startCommunication() {
            let errorCode = printer.print(image.cgImage, copy: 1)
            print("printed done@")
            if errorCode != ERROR_NONE_ {
                print("*** Printer Error when printing ***")
                print("ERROR - \(errorCode)")
            }
            printer.endCommunication()
        }
    }

    // Print Image
    @available(iOS 10.0, *)
    private func printImage(location: String, model: String, ip: String, label: String) {

        let image = UIImage(named: location)
        
        // Specify printer
        let printer = BRPtouchPrinter(printerName: model, interface: CONNECTION_TYPE.WLAN)!
        printer.setIPAddress(ip)
        print("set printer")

        // Print Settings
        let settings = BRPtouchPrintInfo()
        if model.contains("RJ") {
            settings.strPaperName = "CUSTOM"
            printer.setCustomPaperFile(createRJLabel(labelData: label))
        } else {
            settings.strPaperName = label
        }
        settings.nPrintMode = PRINT_FIT
        settings.nAutoCutFlag = OPTION_AUTOCUT
        settings.nHalftone = HALFTONE_DITHER
        printer.setPrintInfo(settings)
        print("set options")
        
        guard printer.isPrinterReady() else {
            print("*** Printer is not Ready ***")
            return
        }

        // Connect, then print
        if printer.startCommunication() {
            //let errorCode = printer.printFiles([location], copy: 1)
            let errorCode = printer.print(image?.cgImage, copy: 1)
            print("printed done@")
            if errorCode != ERROR_NONE_ {
                print("*** Printer Error when printing ***")
                print("ERROR - \(errorCode)")
            }
            printer.endCommunication()
        }
    }
}
