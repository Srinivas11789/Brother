package com.example.brother_demo

import android.R.attr.bitmap
import android.graphics.*
import android.os.AsyncTask
import android.os.Build
import android.text.TextPaint
import android.util.Base64
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
import java.io.File
import java.io.FileOutputStream
import java.io.InputStream


val printerModels = mapOf("QL-1110NWB" to PrinterInfo.Model.QL_1110NWB, "QL-820NWB" to PrinterInfo.Model.QL_820NWB, "RJ-2150" to PrinterInfo.Model.RJ_2150);
val labelSizes = mapOf("103mmx164mm" to LabelInfo.QL1100.W103H164.ordinal, "62mmx8m" to LabelInfo.QL1100.W62.ordinal);
val rjCustomLabels = mapOf("Diecut->100x50" to "rj2150_diecut_100x50x5.bin", "Continuous->58mm" to "rj2150_58mm_continuous.bin");

val motivations = listOf("Lets Do It!", "Vamos!!!", "Cmon!", "You are close!", "One more mile!", "You are racing...!");
//["Where there is a will,there is a way","Sometimes later becomes never","Dream bigger,Do Bigger","Great things never come from comfort zones","You can rock it and nail it","Little Things make Big Days"];
val ops_work = listOf("Breath for a minute..", "Walk for a minute..", "Climb up the stairs 3 times..", "Stare at nature 30 seconds!");

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
                //val tasks = message?.replace("\\[".toRegex(), "")?.replace("\\]".toRegex(), "")?.replace("\\s".toRegex(), "")?.split(",".toRegex())?.dropLastWhile { it.isEmpty() }?.toTypedArray()
                val tasks = message?.replace("\\[".toRegex(), "")?.replace("\\]".toRegex(), "")?.split(",".toRegex())?.dropLastWhile { it.isEmpty() }?.toTypedArray()
                Log.d("TAG", "TASKS - " + tasks.toString());
                AsyncTask.execute({
                    if (tasks != null) {
                        for (t in tasks) {
                            printData(t, printerModel, ip, label)
                            Thread.sleep(10000);
                        }
                    }
                });
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
            val text2 = motivations.shuffled().take(1)[0]
            val text3 = ops_work.shuffled().take(1)[0]
            var decisionStr = ""
            if (text2.length > text3.length) {
                decisionStr = text2
            } else {
                decisionStr = text3
            }
            if (text != null) {
                if (decisionStr.length < text.length) {
                    if (text != null) {
                        decisionStr = text
                    }
                }
            }
            val paint = Paint(Paint.ANTI_ALIAS_FLAG);
            val x = 0;
            val y = 20;
            val b = Bitmap.createBitmap(1000, 1000, Bitmap.Config.ARGB_8888)
            b.eraseColor(Color.WHITE);
            val c = Canvas(b)

            //
            val textPaint: TextPaint = TextPaint();
            textPaint.setTextSize(80F);
            textPaint.setTextAlign(Paint.Align.CENTER);
            textPaint.setAntiAlias(true);
            textPaint.setColor(Color.BLACK);
            textPaint.setTypeface(Typeface.create("Arial", Typeface.BOLD));
            textPaint.setStyle(Paint.Style.FILL);
            //

            val rectText = Rect()
            if (text3 != null) {
                paint.getTextBounds(decisionStr, 0, decisionStr.length, rectText)
            }
            //c.drawRect(rectText, paint);

            //c.translate(x.toFloat(),y.toFloat());
            //c.translate(-x.toFloat(),-y.toFloat());
            //c.rotate(-90F, x + rectText.exactCenterX(), y + rectText.exactCenterY())

            //val tw = (c.getWidth()/2).toFloat()
            val tw = (c.getWidth()/2).toFloat()
            val th = (c.getHeight()/2 + Math.abs(rectText.height())/2).toFloat()
            //c.rotate(-45F, tw + rectText.exactCenterX(), th + rectText.exactCenterY())
            c.drawText(text, tw, th, textPaint)
            textPaint.setTextSize(60F);
            textPaint.setTypeface(Typeface.create("Arial", Typeface.BOLD_ITALIC));
            c.drawText(text3, tw, th+60F, textPaint)
            textPaint.setTextSize(45F);
            textPaint.setTypeface(Typeface.create("Arial", Typeface.ITALIC));
            c.drawText(text2, tw, th+100F, textPaint)

            b;
            /*
            val paint = Paint();
            val x = 0;
            val y = 50;
            val b = Bitmap.createBitmap(164, 100, Bitmap.Config.ARGB_8888)
            b.eraseColor(Color.WHITE);
            val c = Canvas(b)
            //paint.setColor(Color.BLACK);
            //paint.setTextSize(20F);
            //textPaint.setTextAlign(Paint.Align.LEFT);
            //paint.setTypeface(Typeface.create("Arial", Typeface.DEFAULT_BOLD));
           val textPaint: TextPaint = TextPaint();
            textPaint.setTextSize(20F);
            textPaint.setTextAlign(Paint.Align.CENTER);
            textPaint.setAntiAlias(true);
            textPaint.setColor(Color.BLACK);
            textPaint.setTypeface(Typeface.create("Arial", Typeface.BOLD));
            val rectText = android.graphics.Rect()
            val text2 = motivations.shuffled().take(1)[0]
            val text3 = ops_work.shuffled().take(1)[0]
            if (text3 != null) {
                paint.getTextBounds(text3, 0, text3.length, rectText)
            }
            c.translate(x.toFloat(),y.toFloat());
            textPaint.setStyle(Paint.Style.FILL);
            //c.translate(-x.toFloat(),-y.toFloat());
            c.rotate(-90F, x + rectText.exactCenterX(), y + rectText.exactCenterY())
            c.drawRect(rectText, paint);
            c.drawText(text, x.toFloat(), y.toFloat(), textPaint)
            textPaint.setTypeface(Typeface.create("Arial", Typeface.BOLD_ITALIC));
            c.drawText(text3, x.toFloat(), y.toFloat()+30F, textPaint)
            textPaint.setTypeface(Typeface.create("Arial", Typeface.ITALIC));
            c.drawText(text2, x.toFloat(), y.toFloat()+70F, textPaint)
            //c.rotate(45F, c.width.toFloat()/2, c.height.toFloat()/2;
            //c.rotate(-45F, x + rectText.exactCenterX(), y + rectText.exactCenterY())
            b;
            */
        } catch (e: Exception) {
            print(e.message);
            val b = Bitmap.createBitmap(164, 100, Bitmap.Config.ARGB_8888)
            b.eraseColor(Color.WHITE);
            b;
        }
    }

    // Convert text to bitmap image data
    @RequiresApi(Build.VERSION_CODES.M)
    private fun StringToBitMapSave(text: String?): String {
        return try {
            val destDirPath: String = context.filesDir.absolutePath + "/images/";
            /*
            val paint = Paint();
            val x = 0;
            val y = 50;
            val b = Bitmap.createBitmap(164, 100, Bitmap.Config.ARGB_8888)
            b.eraseColor(Color.WHITE);
            val c = Canvas(b)
            //paint.setColor(Color.BLACK);
            //paint.setTextSize(20F);
            //textPaint.setTextAlign(Paint.Align.LEFT);
            //paint.setTypeface(Typeface.create("Arial", Typeface.DEFAULT_BOLD));
            val textPaint: TextPaint = TextPaint();
            textPaint.setTextSize(20F);
            textPaint.setTextAlign(Paint.Align.CENTER);
            textPaint.setAntiAlias(true);
            textPaint.setColor(Color.BLACK);
            textPaint.setTypeface(Typeface.create("Arial", Typeface.BOLD));
            val rectText = android.graphics.Rect()
            val text2 = motivations.shuffled().take(1)[0]
            val text3 = ops_work.shuffled().take(1)[0]
            if (text3 != null) {
                paint.getTextBounds(text3, 0, text3.length, rectText)
            }
            c.translate(x.toFloat(),y.toFloat());
            textPaint.setStyle(Paint.Style.FILL);
            //c.translate(-x.toFloat(),-y.toFloat());
            c.rotate(-90F, x + rectText.exactCenterX(), y + rectText.exactCenterY())
            c.drawRect(rectText, paint);
            c.drawText(text, x.toFloat(), y.toFloat(), textPaint)
            textPaint.setTypeface(Typeface.create("Arial", Typeface.BOLD_ITALIC));
            c.drawText(text3, x.toFloat(), y.toFloat()+30F, textPaint)
            textPaint.setTypeface(Typeface.create("Arial", Typeface.ITALIC));
            c.drawText(text2, x.toFloat(), y.toFloat()+70F, textPaint)
            //c.rotate(45F, c.width.toFloat()/2, c.height.toFloat()/2;
            //c.rotate(-45F, x + rectText.exactCenterX(), y + rectText.exactCenterY())

             */
            val text2 = motivations.shuffled().take(1)[0]
            val text3 = ops_work.shuffled().take(1)[0]
            val paint = Paint(Paint.ANTI_ALIAS_FLAG);
            val x = 0;
            val y = 20;
            val b = Bitmap.createBitmap(500, 500, Bitmap.Config.ARGB_8888)
            b.eraseColor(Color.WHITE);
            val c = Canvas(b)

            //
            val textPaint: TextPaint = TextPaint();
            textPaint.setTextSize(80F);
            textPaint.setTextAlign(Paint.Align.CENTER);
            textPaint.setAntiAlias(true);
            textPaint.setColor(Color.BLACK);
            textPaint.setTypeface(Typeface.create("Arial", Typeface.BOLD));
            textPaint.setStyle(Paint.Style.FILL);
            //

            var decisionStr = ""
            if (text2.length > text3.length) {
                decisionStr = text2
            } else {
                decisionStr = text3
            }
            if (text != null) {
                if (decisionStr.length < text.length) {
                    if (text != null) {
                        decisionStr = text
                    }
                }
            }

            val rectText = Rect()
            if (text3 != null) {
                paint.getTextBounds(decisionStr, 0, decisionStr.length, rectText)
            }
            //c.drawRect(rectText, paint);

            //c.translate(x.toFloat(),y.toFloat());
            //c.translate(-x.toFloat(),-y.toFloat());
            //c.rotate(-90F, x + rectText.exactCenterX(), y + rectText.exactCenterY())

            //val tw = (c.getWidth()/2).toFloat()
            val tw = (c.getWidth()/2).toFloat()
            val th = (c.getHeight()/2 + Math.abs(rectText.height())/2).toFloat()
            c.drawText(text, tw, th, textPaint)
            textPaint.setTextSize(50F);
            textPaint.setTypeface(Typeface.create("Arial", Typeface.BOLD_ITALIC));
            c.drawText(text3, tw, th+60F, textPaint)
            textPaint.setTextSize(30F);
            textPaint.setTypeface(Typeface.create("Arial", Typeface.ITALIC));
            c.drawText(text2, tw, th+100F, textPaint)

            val dir = File(destDirPath)
            if (!dir.exists()) dir.mkdirs()
            val filename = text + ".png"
            val file = File(dir, filename)
            val fOut = FileOutputStream(file)
            b.compress(Bitmap.CompressFormat.PNG, 100, fOut)
            fOut.close();
            return destDirPath+filename
        } catch (e: Exception) {
            print(e.message);
            Log.d("TAG", "ERROR - " + e.message);
            val b = Bitmap.createBitmap(164, 100, Bitmap.Config.ARGB_8888)
            b.eraseColor(Color.WHITE);
            return ""
        }
    }

    // Create the custom label setting to use --> UNUSED < This is another method to use the bin file from assets >
    private fun createLabelRJFromBinFile(label_name: String?): String {
        val destDirPath: String = context.filesDir.absolutePath + "/labels/";
        val destDir = File(destDirPath);
        if (!destDir.exists()) destDir.mkdirs();
        val destFilePath: String = destDirPath + label_name;
        val destFile = File(destFilePath);
        val origin: InputStream = context.assets.open(label_name);
        origin.use { input -> destFile.outputStream().use { output -> input.copyTo(output)}};
        origin.close();
        return destFilePath;
    }

    // Create the custom label setting to use 
    private fun createLabelRJ(label_name: String?): String {
        val destDirPath: String = context.filesDir.absolutePath + "/labels/";
        val destDir = File(destDirPath);
        if (!destDir.exists()) destDir.mkdirs();
        val destFilePath: String = destDirPath + label_name;
        val destFile = File(destFilePath);
        destFile.writeBytes(Base64.decode(label_name, Base64.DEFAULT));
        return destFilePath;
    }

    // Print Image Data
    private fun printData(message: String?, model: String?, ip: String?, label: String?) {
        val printer: Printer = Printer();
        val settings: PrinterInfo = printer.getPrinterInfo();
        settings.printerModel = printerModels[model]
        settings.port = PrinterInfo.Port.NET;
        settings.ipAddress = ip;
        settings.workPath = this.filesDir.absolutePath + "/";
        if (model?.contains("RJ")!!) {
            Log.d("TAG", "Detected RJ Printer");
            settings.paperSize = PrinterInfo.PaperSize.CUSTOM;
            settings.printMode = PrinterInfo.PrintMode.FIT_TO_PAGE;
            settings.customPaper = createLabelRJ(label);
        } else {
            settings.labelNameIndex = labelSizes[label]!!;
            settings.printMode = PrinterInfo.PrintMode.FIT_TO_PAGE;
            settings.isAutoCut = true;
        }
        printer.setPrinterInfo(settings);

        val bitmap = StringToBitMap(message);

        Thread({
            if (printer.startCommunication()) {
                val result: PrinterStatus = printer.printImage(bitmap);
                if (result.errorCode != ErrorCode.ERROR_NONE) {
                    Log.d("TAG", "ERROR - " + result.errorCode);
                    Log.d("TAG", "?");
                }
                printer.endCommunication();
            }
        }).start();
    }

    // Print Image Data
    private fun printDataI(message: String?, model: String?, ip: String?, label: String?) {
        val printer: Printer = Printer();
        val settings: PrinterInfo = printer.getPrinterInfo();
        settings.printerModel = printerModels[model]
        settings.port = PrinterInfo.Port.NET;
        settings.ipAddress = ip;
        settings.workPath = this.filesDir.absolutePath + "/";
        if (model?.contains("RJ")!!) {
            Log.d("TAG", "Detected RJ Printer");
            settings.paperSize = PrinterInfo.PaperSize.CUSTOM;
            settings.printMode = PrinterInfo.PrintMode.FIT_TO_PAGE;
            settings.customPaper = createLabelRJ(label);
        } else {
            settings.labelNameIndex = labelSizes[label]!!;
            settings.printMode = PrinterInfo.PrintMode.FIT_TO_PAGE;
            settings.isAutoCut = true;
        }
        printer.setPrinterInfo(settings);

        val imageFile = StringToBitMapSave(message);
        Log.d("TAG", "file: " + imageFile);
        Log.d("TAG", "Here!");

        Thread({
            if (printer.startCommunication()) {
                val result: PrinterStatus = printer.printFile(imageFile);
                if (result.errorCode != ErrorCode.ERROR_NONE) {
                    Log.d("TAG", "ERROR - " + result.errorCode);
                    Log.d("TAG", imageFile);
                }
                printer.endCommunication();
            }
        }).start();
    }

    // Print Image File
    private fun printImage(imageFile: String?, model: String?, ip: String?, label: String?) {
        val printer: Printer = Printer();
        val settings: PrinterInfo = printer.getPrinterInfo();
        settings.printerModel = printerModels[model];
        settings.port = PrinterInfo.Port.NET;
        settings.ipAddress = ip;
        val dirs = imageFile?.split("/");
        settings.workPath = context.filesDir.absolutePath + "/";
        if (model?.contains("RJ")!!) {
            Log.d("TAG", "Detected RJ Printer");
            settings.paperSize = PrinterInfo.PaperSize.CUSTOM;
            settings.printMode = PrinterInfo.PrintMode.FIT_TO_PAGE;
            settings.customPaper = createLabelRJ(label);
            Log.d("TAG", settings.customPaper);
        } else {
            settings.labelNameIndex = labelSizes[label]!!;
            settings.printMode = PrinterInfo.PrintMode.FIT_TO_PAGE;
            settings.isAutoCut = true;
        }
        printer.setPrinterInfo(settings);

        Thread({
            if (printer.startCommunication()) {
                    val result: PrinterStatus = printer.printFile(imageFile);
                    if (result.errorCode != ErrorCode.ERROR_NONE) {
                        Log.d("TAG", "ERROR - " + result.errorCode);
                        Log.d("TAG", "ss");
                    }
                    printer.endCommunication();
            }
        }).start();
    }
}
