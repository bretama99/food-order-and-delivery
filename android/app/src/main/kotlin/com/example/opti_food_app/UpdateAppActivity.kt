package com.example.opti_food_app
import io.flutter.embedding.android.FlutterActivity
import android.widget.Button
import android.widget.TextView
import android.os.Bundle
import androidx.core.app.ActivityCompat
import android.Manifest
import android.content.pm.PackageManager
import android.widget.Toast
import android.os.AsyncTask
import android.content.Context
import java.net.URL
import java.net.HttpURLConnection
import java.io.File
import android.os.Environment
import java.io.FileOutputStream
import java.io.InputStream
import android.net.Uri
import android.util.Log
import java.io.PrintWriter
import java.io.StringWriter
import android.os.Build
import androidx.core.content.FileProvider
import android.content.Intent
import java.io.Writer


class UpdateAppActivity: FlutterActivity() {
    private lateinit var btnUpdate: Button
    private lateinit var tvPercentage: TextView
    private var fileLength: Int = 0
    private val MY_PERMISSIONS_WRITE_EXTERNAL_STORAGE = 435
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_update_app)
        tvPercentage = findViewById(R.id.tv_download_percentage)

        updateApplication()
    }

    private fun updateApplication() {
        if (ActivityCompat.checkSelfPermission(
                        this@UpdateAppActivity,
                        Manifest.permission.WRITE_EXTERNAL_STORAGE
                ) != PackageManager.PERMISSION_GRANTED
        ) {
            Toast.makeText(this@UpdateAppActivity, "No permission", Toast.LENGTH_LONG).show()
            ActivityCompat.requestPermissions(
                    this@UpdateAppActivity,
                    arrayOf(Manifest.permission.WRITE_EXTERNAL_STORAGE),
                    MY_PERMISSIONS_WRITE_EXTERNAL_STORAGE
            )
        } else {
            Toast.makeText(this@UpdateAppActivity, "Starting download", Toast.LENGTH_LONG).show()
            val atualizaApp = UpdateApp()
            atualizaApp.setContext(applicationContext)
            //atualizaApp.execute("https://optifood.s3.eu-west-3.amazonaws.com/app-debug.apk")
            atualizaApp.execute("https://app.optifood.fr/OwnerDashboard/release/optifood.apk")
        }
    }

     inner class UpdateApp: AsyncTask<String,Int,Void>() {
        private lateinit var context: Context

        fun setContext(contextf: Context) {
            context = contextf
        }

        override fun doInBackground(vararg arg0: String): Void? {
            downloadApk(arg0[0], 1)
            return null
        }

        fun downloadApk(urlString: String?, count: Int) {
            try {
                val url = URL(urlString)
                val c: HttpURLConnection = url.openConnection() as HttpURLConnection
                c.setRequestMethod("GET")
                c.setDoOutput(true)
                c.connect()
                fileLength = c.getContentLength()
                android.util.Log.e("FILE LENGTH","FILE LENGTH"+fileLength);
                //String PATH = "/mnt/sdcard/Download/";

                //File file = new File(PATH);
                val file: File = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS)
                /*if(!file.exists()) {
                    file.mkdirs();
                }*/
                val outputFile = File(file, "update.apk")
                if (outputFile.exists()) {
                    outputFile.delete()
                }
                if (!outputFile.exists()) {
                    outputFile.createNewFile()
                }
                val fos = FileOutputStream(outputFile)
                val inS: InputStream = c.getInputStream()
                val buffer = ByteArray(1024)
                var len1 = 0
                var total = 0
                //while (`is`.read(buffer).also { len1 = it } != -1) {
                while(true){

                    len1 = inS.read(buffer)
                    if(len1 == -1){
                        break;
                    }
                    total += len1
                    fos.write(buffer, 0, len1)
                    //total = total * 100
                    android.util.Log.e("","Total : "+total)
                    android.util.Log.e("","In Loop"+(total * 100 / fileLength))
                    publishProgress((total * 100 / fileLength))
                    //publishProgress((total / fileLength))
                    //publishProgress(5)
                }
                fos.close()
                inS.close()

                //installApp(Uri.parse("/mnt/sdcard/Download/update.apk"),"/mnt/sdcard/Download/update.apk");
                installApp(Uri.parse(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS).getAbsolutePath() + "/update.apk"), Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS).getAbsolutePath() + "/update.apk")
            } catch (e: Exception) {
                Log.e("UpdateAPP", "Update error! " + e.message)
                runOnUiThread(object : Runnable {
                    override fun run() {
                        val writer: Writer = StringWriter()
                        e.printStackTrace(PrintWriter(writer))
                        val s: String = writer.toString()
                        print(s)
                        Toast.makeText(this@UpdateAppActivity, s, Toast.LENGTH_LONG).show()
                    }
                })
                if (count <= 2) {
                    downloadApk(urlString, count + 1)
                }
            }
        }

        override fun onProgressUpdate(vararg values: Int?) {
            super.onProgressUpdate(*values)
            val progress = values[0]
            tvPercentage.setText("$progress%")
        }
    }

    fun installApp(uri: Uri?, destination: String?) {
        val APP_INSTALL_PATH = "\"application/vnd.android.package-archive\""
        val PROVIDER_PATH = ".provider"
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            /*Uri contentUri = FileProvider.getUriForFile(
                    UpdateAppActivity.this,
                    BuildConfig.APPLICATION_ID + PROVIDER_PATH,
                    new File(destination));*/
            val contentUri: Uri = FileProvider.getUriForFile(
                    this@UpdateAppActivity,
                    BuildConfig.APPLICATION_ID,
                    File(destination))
            val install = Intent(Intent.ACTION_VIEW)
            install.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            install.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
            install.putExtra(Intent.EXTRA_NOT_UNKNOWN_SOURCE, true)
            install.setData(contentUri)
            startActivity(install)
        } else {
            /* Intent install = new Intent(Intent.ACTION_VIEW);
            install.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
            install.setDataAndType(
                    uri,
                    APP_INSTALL_PATH
            );
            startActivity(install);*/

            //Intent intent = new Intent(Intent.ACTION_INSTALL_PACKAGE);
            //intent.setData( Uri.fromFile(new File(pathToApk)) );
            //intent.setData(uri);
            //startActivity(intent);

            //Uri apkUri = Uri.fromFile(new File("/mnt/sdcard/Download/update.apk"));
            val apkUri: Uri = Uri.fromFile(File(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS).getAbsolutePath() + "/update.apk"))
            val intent = Intent(Intent.ACTION_VIEW)
            intent.setDataAndType(apkUri, "application/vnd.android.package-archive")
            intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            startActivity(intent)
        }
    }

     /*fun onRequestPermissionsResult(requestCode: Int,  permissions: Array<String?>?,  grantResults: IntArray) {
        //super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == MY_PERMISSIONS_WRITE_EXTERNAL_STORAGE) {
            if (grantResults.size > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                Toast.makeText(this@UpdateAppActivity, "Permission granted", Toast.LENGTH_LONG).show()
                updateApplication()
            } else {
                Toast.makeText(this@UpdateAppActivity, "Write external storage permission not granted", Toast.LENGTH_LONG).show()
            }
        }
    }*/
}