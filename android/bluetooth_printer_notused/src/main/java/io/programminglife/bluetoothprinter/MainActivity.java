package io.programminglife.bluetoothprinter;

import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothSocket;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ListView;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.google.android.material.snackbar.Snackbar;

import java.io.BufferedOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import java.util.UUID;

import io.programminglife.bluetoothprinter.drivers.ESCPOSDriver;
import io.programminglife.bluetoothprinter.listeners.RecyclerItemClickListener;

public class MainActivity extends AppCompatActivity {

    private static final String tag = MainActivity.class.getSimpleName();

    private RelativeLayout mCoordinatorLayout;
    private TextView mTestPrinter;
    private TextView mClosePrinter;
    //private RecyclerView mRecyclerView;
    private RecyclerView mRecyclerView;
    private RecyclerView.LayoutManager mLayoutManager;
    private PairedBtDevicesAdapter mPairedBtDevicesAdapter;

    private BluetoothAdapter mBluetoothAdapter;
    private BluetoothSocket mSocket;
    private BluetoothDevice mDevice;

    private BufferedOutputStream mOutputStream;
    private InputStream mInputStream;
    private Thread mWorkerThread;

    private List<BluetoothDevice> mPairedDevices;
    private byte[] readBuffer;
    private int readBufferPosition;
    private volatile boolean stopWorker;
    private String data = "Not Found";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        getSupportActionBar().hide();

        data = getIntent().getStringExtra("data");
        mCoordinatorLayout = (RelativeLayout) findViewById(R.id.main_layout);
        mTestPrinter = (TextView)findViewById(R.id.test_printer);
        mClosePrinter = (TextView)findViewById(R.id.close_printer);

        mRecyclerView = (RecyclerView) findViewById(R.id.paired_bt_devices);
        mLayoutManager = new LinearLayoutManager(this);
        mRecyclerView.setLayoutManager(mLayoutManager);
        mPairedDevices = findPairedBtDevices();
        mPairedBtDevicesAdapter = new PairedBtDevicesAdapter(MainActivity.this,mPairedDevices);
        mRecyclerView.setAdapter(mPairedBtDevicesAdapter);

        setInteraction();
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.menu_main, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        int id = item.getItemId();

        if (id == R.id.action_settings) {
            return true;
        }

        return super.onOptionsItemSelected(item);
    }

    private void setInteraction() {
        mRecyclerView.addOnItemTouchListener(
                new RecyclerItemClickListener(this, new RecyclerItemClickListener.OnItemClickListener() {
                    @Override
                    public void onItemClick(View view, int position) {
                        mDevice = mPairedDevices.get(position);
                        openBtConnection();
                    }
                })
        );
        /*mRecyclerView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> adapterView, View view, int i, long l) {
                mDevice = mPairedDevices.get(i);
                openBtConnection();
            }
        });*/

        mTestPrinter.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                sendDataToPrinter();
            }
        });

        mClosePrinter.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                closeBT();
            }
        });
    }

    private List<BluetoothDevice> findPairedBtDevices() {
        List<BluetoothDevice> pairedBtDevices = new ArrayList<BluetoothDevice>();

        mBluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
        if(mBluetoothAdapter == null) {
            Snackbar.make(mCoordinatorLayout, "No bluetooth adapter available", Snackbar.LENGTH_SHORT).show();
        }
        if (!mBluetoothAdapter.isEnabled()) {
            Intent enableBluetooth = new Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE);
            startActivityForResult(enableBluetooth, 0);
        }

        Set<BluetoothDevice> bondedDevices = mBluetoothAdapter.getBondedDevices();
        if(bondedDevices.size() > 0) {
            for(BluetoothDevice bluetoothDevice : bondedDevices) {
                pairedBtDevices.add(bluetoothDevice);
            }
        }

        return pairedBtDevices;
    }

    private void openBtConnection() {
        try {
            // Standard SerialPortService ID
            UUID uuid = UUID.fromString("00001101-0000-1000-8000-00805f9b34fb");
            mSocket = mDevice.createRfcommSocketToServiceRecord(uuid);
            mSocket.connect();
            OutputStream outputStream = mSocket.getOutputStream();
            mOutputStream = new BufferedOutputStream(outputStream);
            mInputStream = mSocket.getInputStream();

            beginListenForData();

            Snackbar.make(mCoordinatorLayout, "Bluetooth connection opened", Snackbar.LENGTH_SHORT).show();
            sendDataToPrinter();
        } catch (Exception e) {
            Log.e(tag, e.getMessage(), e);
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
                                                Snackbar.make(mCoordinatorLayout, "Printer is ready", Snackbar.LENGTH_SHORT).show();
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
            Log.e(tag, e.getMessage(), e);
        }
    }



    private void sendDataToPrinter() {
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

            ArrayList addressList = (ArrayList<String>) getIntent().getSerializableExtra("address");
            ArrayList headingList = (ArrayList<String>) getIntent().getSerializableExtra("heading");
            ArrayList itemList = (ArrayList<String>) getIntent().getSerializableExtra("items");
            String total = getIntent().getStringExtra("total");
            ArrayList footerList = (ArrayList<String>) getIntent().getSerializableExtra("footer");




            escposDriver.boldOn(mOutputStream);
            for(int i=0;i<addressList.size();i++)
            {
                escposDriver.printLineAlignCenter(mOutputStream,addressList.get(i).toString());
            }
            escposDriver.boldOff(mOutputStream);

            for(int i=0;i<headingList.size();i++)
            {
                escposDriver.addItem(mOutputStream,headingList.get(i).toString(),true,31);
            }
            escposDriver.printLineAlignCenter(mOutputStream,"--------------------------");
            for(int i=0;i<itemList.size();i++)
            {
                escposDriver.addItem(mOutputStream,itemList.get(i).toString(),false,31);
            }
            escposDriver.printLineAlignCenter(mOutputStream,"--------------------------");
            escposDriver.addItem(mOutputStream,total,false,31);
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

            Snackbar.make(mCoordinatorLayout, "Data sent", Snackbar.LENGTH_SHORT).show();
            closeBT();
        } catch (Exception e) {
            Log.e(tag, e.getMessage(), e);
        }
    }

    void closeBT() {
        try {
            stopWorker = true;
            mOutputStream.close();
            mInputStream.close();
            mSocket.close();

            Snackbar.make(mCoordinatorLayout, "Bluetooth closed", Snackbar.LENGTH_SHORT).show();
            finish();
        } catch (Exception e) {
            Log.e(tag, e.getMessage(), e);
        }
    }
}
