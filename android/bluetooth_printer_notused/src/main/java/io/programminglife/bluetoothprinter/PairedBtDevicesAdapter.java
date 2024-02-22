package io.programminglife.bluetoothprinter;

import android.bluetooth.BluetoothDevice;
import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ImageView;
import android.widget.TextView;


import androidx.recyclerview.widget.RecyclerView;

import java.util.ArrayList;
import java.util.List;

import io.programminglife.bluetoothprinter.R;

/**
 * Created by andrei on 10/29/15.
 */
public class PairedBtDevicesAdapter extends RecyclerView.Adapter<PairedBtDevicesAdapter.PairedBtDevicesViewHolder> {
//public class PairedBtDevicesAdapter extends ArrayAdapter {

    List<BluetoothDevice> pairedBtDevices;
    Context context;

    public PairedBtDevicesAdapter(Context context,List<BluetoothDevice> pairedBtDevicesDataSet) {
        //super(context,R.layout.bt_device_item);
        this.pairedBtDevices = pairedBtDevicesDataSet;
        this.context = context;
    }

    public static class PairedBtDevicesViewHolder extends RecyclerView.ViewHolder {
        public TextView mPrinterName;
        public ImageView mPrinterIcon, mTickIcon;

        public PairedBtDevicesViewHolder(View itemView) {
            super(itemView);
            mPrinterIcon = (ImageView)itemView.findViewById(R.id.printer_icon);
            mPrinterName = (TextView)itemView.findViewById(R.id.printer_name);
            mTickIcon = (ImageView)itemView.findViewById(R.id.iv_tick);
        }
    }

   /* @NonNull
    @Override
    public View getView(int position, @Nullable View convertView, @NonNull ViewGroup parent) {
        //super.getView(position, convertView, parent);
        LayoutInflater layoutInflater = (LayoutInflater) context.getSystemService(context.LAYOUT_INFLATER_SERVICE);
        View view = layoutInflater.inflate(R.layout.bt_device_item,null);
        PairedBtDevicesViewHolder pairedBtDevicesViewHolder = new PairedBtDevicesViewHolder(view);
        pairedBtDevicesViewHolder.mPrinterName.setText(pairedBtDevices.get(position).getName());
        return  view;
    }*/

    @Override
    public PairedBtDevicesViewHolder onCreateViewHolder(ViewGroup viewGroup, int i) {
        View view = LayoutInflater.from(viewGroup.getContext()).inflate(R.layout.bt_device_item, viewGroup, false);
        PairedBtDevicesViewHolder viewHolder = new PairedBtDevicesViewHolder(view);
        return viewHolder;
    }

    @Override
    public void onBindViewHolder(PairedBtDevicesViewHolder pairedBtDevicesViewHolder, int position) {
        pairedBtDevicesViewHolder.mPrinterName.setText(pairedBtDevices.get(position).getName());
        //pairedBtDevicesViewHolder.mPrinterName.setText("Testing");
    }

    @Override
    public int getItemCount() {
        return pairedBtDevices.size();
    }

    @Override
    public void onAttachedToRecyclerView(RecyclerView recyclerView) {
        super.onAttachedToRecyclerView(recyclerView);
    }
}
//