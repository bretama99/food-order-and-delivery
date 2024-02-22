package io.programminglife.bluetoothprinter;

import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothSocket;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;
import android.view.View;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.google.android.material.snackbar.Snackbar;

import java.io.BufferedOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import java.util.UUID;

import io.programminglife.bluetoothprinter.listeners.RecyclerItemClickListener;

public class SelectPrinterActivity extends AppCompatActivity {

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
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_select_printer);

        mRecyclerView = (RecyclerView) findViewById(R.id.paired_bt_devices);
        mLayoutManager = new LinearLayoutManager(this);
        mRecyclerView.setLayoutManager(mLayoutManager);
        mPairedDevices = findPairedBtDevices();
        mPairedBtDevicesAdapter = new PairedBtDevicesAdapter(SelectPrinterActivity.this,mPairedDevices);
        mRecyclerView.setAdapter(mPairedBtDevicesAdapter);

        setInteraction();
    }

    private void setInteraction() {
        mRecyclerView.addOnItemTouchListener(
                new RecyclerItemClickListener(this, new RecyclerItemClickListener.OnItemClickListener() {
                    @Override
                    public void onItemClick(View view, int position) {
                        mDevice = mPairedDevices.get(position);
                        Intent intent = new Intent();
                        intent.putExtra("device",mDevice);
                        setResult(RESULT_OK,intent);
                        finish();
                        //openBtConnection();
                    }
                })
        );

        /*mTestPrinter.setOnClickListener(new View.OnClickListener() {
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
        });*/
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
}