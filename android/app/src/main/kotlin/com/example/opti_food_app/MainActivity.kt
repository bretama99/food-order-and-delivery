package com.example.opti_food_app

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.os.IBinder
import android.widget.Toast
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel;
import io.flutter.embedding.android.FlutterActivity
//import io.programminglife.bluetoothprinter.SelectPrinterActivity
import com.posprinter.printdemo.activity.SelectPrinterActivity
import com.posprinter.printdemo.utils.BackgroundPrint
import io.flutter.plugin.common.MethodChannel.Result

import net.posprinter.posprinterface.IMyBinder
import net.posprinter.posprinterface.UiExecute
import net.posprinter.service.PosprinterService
import java.util.ArrayList


class MainActivity: FlutterActivity() {
    //SelectPrinterActivity av;
    private val CHANNEL = "optifood.flutter.manager/print"
    private var pendingResult: Result? = null
    private var binder: IMyBinder? = null;
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            pendingResult = result

            if(call.method == "showToast") {
                showToast();
            }
            else if(call.method == "selectPrinter"){
                selectPrinter();
            }
            else if(call.method == "connectPrinter"){
                 //String macAddress = call.argument<String>("mac")

                //String macAddress = args["mac"] as String
                //Toast.makeText(applicationContext,args.map { "${it.key}: ${it.value}" }.joinToString(", "),Toast.LENGTH_SHORT).show()
                val args = call.arguments as Map<*, *>
                var a = args["mac"] as String
                //Toast.makeText(applicationContext,a,Toast.LENGTH_SHORT).show()
                //println(args.map { "${it.key}: ${it.value}" }.joinToString(", "))
                connectPrinter(a);
            }
            else if(call.method == "printTestMessage"){
                printTestMessage(binder!!,"Printing test message in flutter!")
            }
            else if(call.method == "printTicket"){
                val args = call.arguments as Map<*, *>
                var a = args["mac"] as String
                var headingList = args["heading_list"] as ArrayList<String>
                var addressList = args["address_list"] as ArrayList<String>
                var foodItemsList = args["fooditems_list"] as ArrayList<String>
                var footerList = args["footer_list"] as ArrayList<String>
                var deliveryCharges = args["delivery_fee"] as String
                var nightCharges = args["night_fee"] as String
                var totalPrice = args["total_price"] as String
                var noOfTicket = args["no_of_ticket"] as Int
                var isPrintMainTicket = args["is_print_main_ticket"] as Boolean
                var isPrintOrderNumberTicket = args["is_print_order_number_ticket"] as Boolean
                printTicket(a,headingList,addressList,foodItemsList,deliveryCharges,nightCharges,totalPrice,footerList,noOfTicket,isPrintMainTicket,isPrintOrderNumberTicket);
            }
            else if(call.method == "updateApp"){
                //Toast.makeText(applicationContext,"update app",Toast.LENGTH_SHORT).show()
                val intent = Intent(context, UpdateAppActivity::class.java)
                startActivity(intent)
            }
            else {
                Toast.makeText(applicationContext,"channel created",Toast.LENGTH_SHORT).show()
            }
        }
    }
    fun showToast(){
        Toast.makeText(applicationContext,"this is toast message",Toast.LENGTH_SHORT).show();

    }
    fun selectPrinter(){
        val intent = Intent(context, SelectPrinterActivity::class.java)
        startActivityForResult(intent,100)
    }

    fun connectPrinter(mac: String){
         val connection = object : ServiceConnection {
            override fun onServiceConnected(className: ComponentName, service: IBinder) {
                Toast.makeText(applicationContext,"service connected",Toast.LENGTH_SHORT).show();
                // We've bound to LocalService, cast the IBinder and get LocalService instance.
                //val binder = service as LocalService.LocalBinder
                binder = service as IMyBinder
               // mService = binder.getService()
               // mBound = true
                binder?.connectBtPort(mac,object: UiExecute {
                    override fun onsucess() {
                        Toast.makeText(applicationContext,"connection success",Toast.LENGTH_SHORT).show();
                        printTestMessage(binder!!,"L'imprimante est désormais connectée !")
                    }
                    override fun onfailed() {
                        Toast.makeText(applicationContext,"connection failed",Toast.LENGTH_SHORT).show();
                    }
                })
            }

            override fun onServiceDisconnected(arg0: ComponentName) {
               // mBound = false
            }
        }

        Intent(this, PosprinterService::class.java).also { intent ->
            //bindService(intent, connection, Context.BIND_AUTO_CREATE)
            bindService(intent, connection, android.content.Context.BIND_AUTO_CREATE)
        }
    }

    fun printTestMessage(binder: IMyBinder,message: String){
        BackgroundPrint().printTestMessage(binder, message);
        Toast.makeText(applicationContext,"Ticket Printed",Toast.LENGTH_SHORT).show();
    }

    fun printTicket(mac: String,headingList: ArrayList<String>,addressList: ArrayList<String>, foodItems: ArrayList<String>,deliveryFee: String,nightFee: String,totalPrice: String,footerList: ArrayList<String>,noOfTocket: Int,isPrintMainTicket: Boolean,isPrintOrderNumberTicket: Boolean){
        /*new BackgroundPrint(mContext, UserSession.getInstance(activity).getPrinterMacAddress()).printTicket((IMyBinder) binder, addressList, headingList, foodItems, delFee, nightModeFee, total, footerList,
        UserSession.getInstance(activity).getPrintSize(),
        UserSession.getInstance(activity).getPrintCopies(), name, code,
        UserSession.getInstance(activity).getPrintOrderNoTicket(),
        UserSession.getInstance(activity).getPrintMainTicket());*/
        BackgroundPrint(applicationContext,mac).printTicket(binder,addressList,headingList,foodItems,deliveryFee,nightFee,totalPrice,footerList,
                    "10",
                noOfTocket,"Cp858",19,
                isPrintOrderNumberTicket,
                isPrintMainTicket
                );
        Toast.makeText(applicationContext,"Main Ticket Printed",Toast.LENGTH_SHORT).show();
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        //if (resultCode == Activity.RESULT_OK && requestCode == 100) {
        if (resultCode == RESULT_OK && requestCode == 100) {
            val value: String? = data?.getStringExtra("mac_address")
            //Toast.makeText(applicationContext,value,Toast.LENGTH_SHORT).show();
            //pendingResult?.success(value);
            if(value!=null)
                connectPrinter(value)

            pendingResult?.success(value);
        }
        else{
           // pendingResult?.success(null);
        }
    }
}
