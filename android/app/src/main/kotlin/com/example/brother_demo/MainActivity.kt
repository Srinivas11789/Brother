package com.example.brother_demo

import android.R.attr.bitmap
import android.content.Intent
import android.graphics.*
import android.os.Build
import android.util.Log
import androidx.annotation.NonNull
import androidx.annotation.RequiresApi
import com.brother.ptouch.sdk.LabelInfo
import com.brother.ptouch.sdk.Printer
import com.brother.ptouch.sdk.PrinterInfo
import com.brother.ptouch.sdk.PrinterInfo.ErrorCode
import com.brother.ptouch.sdk.PrinterStatus
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import android.content.Context
import java.io.File

val printerModels = mapOf("QL-1110NWB" to PrinterInfo.Model.QL_1110NWB, "QL-820NWB" to PrinterInfo.Model.QL_820NWB);
val labelSizes = mapOf("103mmx164mm" to LabelInfo.QL1100.W103H164.ordinal, "62mmx8m" to LabelInfo.QL1100.W62.ordinal);

class MainActivity: FlutterActivity() {
    // Channel Name
    companion object {
        const val CHANNEL = "com.example.brother_demo"
    }
    // For each channel message calls do something...
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
        MethodChannel(flutterEngine.dartExecutor, CHANNEL).setMethodCallHandler {call, result ->
            if (call.method == "printLabel") {
                val message = call.argument("message") as? String
                val printerModel = call.argument("printerModel") as? String
                val ip = call.argument("ip") as? String
                val label = call.argument("label") as? String
                printData(message, printerModel, ip, label)
                result.success(true) 
            } else if (call.method == "printImage") {
                val imageFile = call.argument("imageFile") as? String
                val printerModel = call.argument("printerModel") as? String
                val ip =  call.argument("ip") as? String
                val label = call.argument("label") as? String
                printImage(imageFile, printerModel, ip, label)
                result.success(true) 
            } else {
                result.notImplemented()
            }
        }
    }

    // Convert text to bitmap image data
    @RequiresApi(Build.VERSION_CODES.M)
    private fun StringToBitMap(text: String?): Bitmap? {
        return try {
            val paint = Paint();
            val x = 0;
            val y = 50;
            val b = Bitmap.createBitmap(164, 100, Bitmap.Config.ARGB_8888)
            b.eraseColor(Color.WHITE);
            val c = Canvas(b)
            paint.setColor(Color.BLACK);
            paint.setTextSize(10F);
            val rectText = android.graphics.Rect()
            if (text != null) {
                paint.getTextBounds(text, 0, text.length, rectText)
            }
            paint.setStyle(Paint.Style.FILL);
            //c.rotate(90f, c.width.toFloat()/2, c.height.toFloat()/2)
            c.drawRect(rectText, paint);
            c.drawText(text, x.toFloat(), y.toFloat(), paint)
            c.rotate(90f, c.width.toFloat()/2, c.height.toFloat()/2)
            b;
        } catch (e: Exception) {
            print(e.message);
            val b = Bitmap.createBitmap(164, 100, Bitmap.Config.ARGB_8888)
            b.eraseColor(Color.WHITE);
            b;
        }
    }

    // Print Image Data
    private fun printData(message: String?, model: String?, ip: String?, label: String?) {
        val printer: Printer = Printer();
        val settings: PrinterInfo = printer.getPrinterInfo();
        settings.printerModel = printerModels[model]
        settings.port = PrinterInfo.Port.NET;
        settings.ipAddress = ip;
        //settings.workPath = context.getFilesDir().absolutePath + "/";
        // settings.workPath = context.getCacheDir() + File.separator + "workPath";
        settings.workPath = context.filesDir.absolutePath + "/";
        settings.labelNameIndex = labelSizes[label]!! //LabelInfo.QL1100.W102H51.ordinal;
        settings.printMode = PrinterInfo.PrintMode.FIT_TO_PAGE;
        //settings.paperSize = "103mmx164mm"
        settings.isAutoCut = true;
        printer.setPrinterInfo(settings);

        print("called here");
        println(label);
        println(ip);
        val bitmap = StringToBitMap(message);
        print("Done converting...");
        println(label);
        println(ip);
        println(bitmap);

        Thread({
            if (printer.startCommunication()) {
                val result: PrinterStatus = printer.printImage(bitmap);
                if (result.errorCode != ErrorCode.ERROR_NONE) {
                    Log.d("TAG", "ERROR - " + result.errorCode);
                }
                printer.endCommunication();
            }
        }).start();
    }

    private fun printImage(imageFile: String?, model: String?, ip: String?, label: String?) {
        val printer: Printer = Printer();
        val settings: PrinterInfo = printer.getPrinterInfo();
        settings.printerModel = printerModels[model];
        settings.port = PrinterInfo.Port.NET;
        settings.ipAddress = ip;
        //settings.workPath = context.getFilesDir().getAbsolutePath() + "/";
        //settings.workPath = File.separator + context.cacheDir + File.separator + "workPath";
        val dirs = imageFile?.split("/");

        /*
        if (imageFile != null) {
            if (!imageFile.contains("storage")) {
                //settings.workPath = dirs.joinToString("/", "", "", dirs.size - 2, "")
                settings.workPath = context.filesDir.absolutePath + "/";
            }
        }
        */
        settings.workPath = context.filesDir.absolutePath + "/";
        settings.labelNameIndex = labelSizes[label]!! //LabelInfo.QL1100.W102H51.ordinal;
        settings.printMode = PrinterInfo.PrintMode.FIT_TO_PAGE;
        //settings.paperSize = "103mmx164mm"
        settings.isAutoCut = true;
        printer.setPrinterInfo(settings);

        println("called here at image");
        println(settings.workPath);
        println(imageFile);

        Thread({
            if (printer.startCommunication()) {
                    val result: PrinterStatus = printer.printFile(imageFile); //printer.printFile(dirs?.get(dirs.size-1)); //
                    if (result.errorCode != ErrorCode.ERROR_NONE) {
                        Log.d("TAG", "ERROR - " + result.errorCode);
                    }
                    printer.endCommunication();
            }
        }).start();
    }
}
