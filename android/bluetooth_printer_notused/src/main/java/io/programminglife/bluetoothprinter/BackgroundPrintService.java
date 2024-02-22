package io.programminglife.bluetoothprinter;

import android.app.Service;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothSocket;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Binder;
import android.os.Handler;
import android.os.IBinder;
import android.preference.PreferenceManager;

import androidx.annotation.Nullable;

import java.io.BufferedOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.Set;
import java.util.UUID;

import io.programminglife.bluetoothprinter.drivers.ESCPOSDriver;

public class BackgroundPrintService extends Service {

    private BluetoothDevice mDevice;
    private BluetoothSocket mSocket;
    private BufferedOutputStream mOutputStream;
    private InputStream mInputStream;
    private Thread mWorkerThread;

    private byte[] readBuffer;
    private int readBufferPosition;
    private volatile boolean stopWorker;

    public BackgroundPrintService()
    {

    }
    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        super.onStartCommand(intent, flags, startId);
        return START_STICKY;
    }

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return new BackgroundPrinterBinder();
    }

    public class BackgroundPrinterBinder extends Binder {
        public BackgroundPrintService getService() {
            // Return this instance of LocalService so clients can call public methods
            return BackgroundPrintService.this;
        }
    }

    public void openBtConnection(BluetoothDevice mDevice) {
        try {
            // Standard SerialPortService ID
            if(mSocket!=null&&mSocket.isConnected())
            {
                return;
            }
            UUID uuid = UUID.fromString("00001101-0000-1000-8000-00805f9b34fb");
            mSocket = mDevice.createRfcommSocketToServiceRecord(uuid);
            mSocket.connect();
            OutputStream outputStream = mSocket.getOutputStream();
            mOutputStream = new BufferedOutputStream(outputStream);
            mInputStream = mSocket.getInputStream();

            beginListenForData();

            //Snackbar.make(mCoordinatorLayout, "Bluetooth connection opened", Snackbar.LENGTH_SHORT).show();
            //sendDataToPrinter();
        } catch (Exception e) {
            e.printStackTrace();
            //Log.e(tag, e.getMessage(), e);
        }
    }

    private void beginListenForData() {
        try {
            final Handler handler = new Handler();

            // This is the ASCII code for a newline character
            final byte delimiter = 10;

            stopWorker = false;
            readBufferPosition = 0;
            readBuffer = new byte[1024];

            mWorkerThread = new Thread(new Runnable() {
                public void run() {
                    while (!Thread.currentThread().isInterrupted() && !stopWorker) {
                        try {
                            int bytesAvailable = mInputStream.available();
                            if (bytesAvailable > 0) {
                                byte[] packetBytes = new byte[bytesAvailable];
                                mInputStream.read(packetBytes);
                                for (int i = 0; i < bytesAvailable; i++) {
                                    byte readByte = packetBytes[i];
                                    if (readByte == delimiter) {
                                        byte[] encodedBytes = new byte[readBufferPosition];
                                        System.arraycopy(readBuffer, 0,
                                                encodedBytes, 0,
                                                encodedBytes.length);
                                        final String data = new String(encodedBytes, "US-ASCII");
                                        readBufferPosition = 0;
                                        handler.post(new Runnable() {
                                            public void run() {
                                                //Snackbar.make(mCoordinatorLayout, "Printer is ready", Snackbar.LENGTH_SHORT).show();
                                            }
                                        });
                                    } else {
                                        readBuffer[readBufferPosition++] = readByte;
                                    }
                                }
                            }
                        } catch (IOException ex) {
                            stopWorker = true;
                        }
                    }

                }
            });
            mWorkerThread.start();
        } catch (Exception e) {
            //Log.e(tag, e.getMessage(), e);
        }
    }

    public void printTicket(final BluetoothDevice mDevice, final ArrayList headingList, final ArrayList itemList, final ArrayList addressList, final String total, final ArrayList footerList)
    {

        if(mSocket==null||mSocket.isConnected()==false)
        {
            openBtConnection(mDevice);
        }

        sendDataToPrinter(headingList, itemList, addressList, total, footerList);

    }

    private void sendDataToPrinter(ArrayList headingList, ArrayList itemList, ArrayList addressList, String total, ArrayList footerList) {
        try {
            ESCPOSDriver escposDriver = new ESCPOSDriver();
            String msgLeft = "Left";
            msgLeft += "\n";
            String msgCenter = "Center";
            msgCenter += "\n";
            String msgRight = "Right";
            msgRight += "\n";

            //Initialize
            escposDriver.initPrint(mOutputStream);

            //ArrayList addressList = (ArrayList<String>) getIntent().getSerializableExtra("address");
            //ArrayList headingList = (ArrayList<String>) getIntent().getSerializableExtra("heading");
            //ArrayList itemList = (ArrayList<String>) getIntent().getSerializableExtra("items");
            //String total = getIntent().getStringExtra("total");
            //ArrayList footerList = (ArrayList<String>) getIntent().getSerializableExtra("footer");

            SharedPreferences preferences = PreferenceManager.getDefaultSharedPreferences(getApplicationContext());
            int spaces = preferences.getInt("spaces",31);


            escposDriver.boldOn(mOutputStream);
            for(int i=0;i<addressList.size();i++)
            {
                escposDriver.printLineAlignCenter(mOutputStream,addressList.get(i).toString());
            }
            escposDriver.boldOff(mOutputStream);

            for(int i=0;i<headingList.size();i++)
            {
                escposDriver.addItem(mOutputStream,headingList.get(i).toString(),true,spaces);
                //escposDriver.printLineAlignRight(mOutputStream,headingList.get(i).toString());
            }
            escposDriver.printLineAlignCenter(mOutputStream,"--------------------------");
            for(int i=0;i<itemList.size();i++)
            {
                escposDriver.addItem(mOutputStream,itemList.get(i).toString(),false,spaces);
            }
            escposDriver.printLineAlignCenter(mOutputStream,"--------------------------");
            escposDriver.addItem(mOutputStream,total,false,spaces);
            escposDriver.nextLine(mOutputStream);
            for(int i=0;i<footerList.size();i++) {
                if(i==footerList.size()-1)
                {
                    escposDriver.nextLine(mOutputStream);
                    escposDriver.nextLine(mOutputStream);
                    escposDriver.nextLine(mOutputStream);
                }

                {
                    escposDriver.printLineAlignCenter(mOutputStream, footerList.get(i).toString());
                }
            }
           /* escposDriver.boldOn(mOutputStream);
            escposDriver.printLineAlignCenter(mOutputStream,"BON DE COMMANDE");
            escposDriver.printLineAlignCenter(mOutputStream,"No 12");
            escposDriver.boldOff(mOutputStream);

            escposDriver.addItem(mOutputStream,"DATE : 30-11-2019");
            escposDriver.addItem(mOutputStream,"HEUERE : 13:07:54");
            escposDriver.addItem(mOutputStream,"TYPE : Sur Place");
            escposDriver.printLineAlignCenter(mOutputStream,"-----------------");
            escposDriver.addItem(mOutputStream,"1*Poulet Curry");
            escposDriver.addItem(mOutputStream,"1*Poulet Mexicain");
*/

            escposDriver.flushCommand(mOutputStream);

            mOutputStream.flush();

            //Snackbar.make(mCoordinatorLayout, "Data sent", Snackbar.LENGTH_SHORT).show();
            //closeBT();
        } catch (Exception e) {
            // Log.e(tag, e.getMessage(), e);
        }
    }

    void closeBT() {
        try {
            stopWorker = true;
            mOutputStream.close();
            mInputStream.close();
            mSocket.close();

            //Snackbar.make(mCoordinatorLayout, "Bluetooth closed", Snackbar.LENGTH_SHORT).show();
            //finish();
        } catch (Exception e) {
            //Log.e(tag, e.getMessage(), e);
        }
    }

    public static BluetoothDevice getSelectedBluetoothDevice(String macAddress)
    {
        //List<BluetoothDevice> pairedBtDevices = new ArrayList<BluetoothDevice>();

        BluetoothAdapter mBluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
        BluetoothDevice selectedBluetoothDevice = null;
        if(mBluetoothAdapter == null) {
            //Snackbar.make(mCoordinatorLayout, "No bluetooth adapter available", Snackbar.LENGTH_SHORT).show();
        }
        /*if (!mBluetoothAdapter.isEnabled()) {
            Intent enableBluetooth = new Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE);
            startActivityForResult(enableBluetooth, 0);
        }*/

        Set<BluetoothDevice> bondedDevices = mBluetoothAdapter.getBondedDevices();
        if(bondedDevices.size() > 0) {
            for(BluetoothDevice bluetoothDevice : bondedDevices) {
                //pairedBtDevices.add(bluetoothDevice);
                if(macAddress.equalsIgnoreCase(bluetoothDevice.getAddress()))
                {
                    selectedBluetoothDevice = bluetoothDevice;
                }
            }
        }
        return selectedBluetoothDevice;
    }
}
