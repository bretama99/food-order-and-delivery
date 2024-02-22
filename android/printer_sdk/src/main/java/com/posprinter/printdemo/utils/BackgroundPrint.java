package com.posprinter.printdemo.utils;

import android.content.ComponentName;
import android.content.Context;
import android.content.ServiceConnection;
import android.os.IBinder;
import android.util.Log;
import android.widget.Toast;

import com.posprinter.printdemo.R;
import com.posprinter.printdemo.activity.MainActivity;

import net.posprinter.posprinterface.IMyBinder;
import net.posprinter.posprinterface.ProcessData;
import net.posprinter.posprinterface.UiExecute;
import net.posprinter.utils.DataForSendToPrinterPos80;

import java.nio.Buffer;
import java.nio.ByteBuffer;
import java.nio.charset.Charset;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class BackgroundPrint {

    String macAddress;
   // Context mContext;
    public BackgroundPrint(Context context,String macAddress)
    {
        //mContext = context;
        this.macAddress = macAddress;
    }
    public BackgroundPrint(){

    }
    public void printTicket(IMyBinder binder, final ArrayList addressList, final ArrayList headingList,
                          final ArrayList itemList,final String deliveryFee, final String nightFee,final String total, final ArrayList footerList,
                            final String printSize,int printCount,
                            final String name,final int code,boolean isPrintOrderNoTicket,boolean isPrintMainTicket){

        if(isPrintMainTicket) {
            for (int i = 0; i < printCount; i++) {
                try {
                    printText(binder, addressList, headingList, itemList,deliveryFee,nightFee, total, footerList, printSize, name, code);
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }
        if(isPrintOrderNoTicket)
        {
            printOrderNumberTicket(binder,addressList,printSize,name,code);
        }
    }
    private void printText(final IMyBinder binder, final ArrayList addressList, final ArrayList headingList,
                           final ArrayList itemList, final String deliveryFee,final String nightFee,final String total, final ArrayList footerList,
                           final String printSize, final String name, final int code){
        //final int printCopies = Integer.parseInt(etPrintCopies.getText().toString());

        /*final ArrayList addressList = (ArrayList<String>) getIntent().getSerializableExtra("address");
        final ArrayList headingList = (ArrayList<String>) getIntent().getSerializableExtra("heading");
        final ArrayList itemList = (ArrayList<String>) getIntent().getSerializableExtra("items");
        final String total = getIntent().getStringExtra("total");
        final ArrayList footerList = (ArrayList<String>) getIntent().getSerializableExtra("footer");*/
        binder.writeDataByYouself(
                new UiExecute() {
                    @Override
                    public void onsucess() {

                    }

                    @Override
                    public void onfailed() {
                       //Toast.makeText(mContext,"Failed Print, Trying to reconnect "+macAddress,Toast.LENGTH_LONG).show();
                        if(macAddress == null)
                        {
                            return;
                        }
                        binder.connectBtPort(macAddress, new UiExecute() {
                            @Override
                            public void onsucess() {
                                //Toast.makeText(mContext,"Reconnect successful",Toast.LENGTH_LONG).show();

                                //printText(binder, addressList, headingList, itemList,deliveryFee, total, footerList, printSize, name, code); //COMMENTED TO CHECK PROBLEM OF LOT OF TICKETS
                            }

                            @Override
                            public void onfailed() {
                                //Toast.makeText(mContext,"Reconnect failed",Toast.LENGTH_LONG).show();
                            }
                        });
                    }
                }, new ProcessData() {
                    @Override
                    public List<byte[]> processDataBeforeSend() {

                        byte[] boldStart = {0x1B, 0x45, 0x01};
                        byte[] boldEnd = {0x1B, 0x45, 0x00};
                        List<byte[]> list=new ArrayList<byte[]>();
                        //creat a text ,and make it to byte[],
                        //String str=text.getText().toString();
                        // if (str.equals(null)||str.equals("")){
                        if(false)
                        {
                            //showSnackbar(getString(R.string.text_for));
                        }else {
                            //initialize the printer
//                            list.add( DataForSendToPrinterPos58.initializePrinter());
                            list.add(DataForSendToPrinterPos80.initializePrinter());
                            list.add(DataForSendToPrinterPos80.selectCharacterSize(10));

                            for(int i=0;i<addressList.size();i++)
                            {
                                list.add(DataForSendToPrinterPos80.selectCharacterSize(10));
                                String data = addressList.get(i).toString();

                                if(data.contains("TEL :")==false) {
                                    data = addSpaces(data,printSize);
                                }
                                byte[] data1= StringUtils.strTobytesSpecialSymbol(data);
                                list.add(DataForSendToPrinterPos80.selectAlignment(1));
                                if(addressList.get(i).toString().contains("N° "))
                                {
                                    //list.add(DataForSendToPrinterPos80.selectCharacterSize(27));
                                    byte[] fortSize = {0x1D, 0x21, 0x23};
                                    list.add(fortSize);
                                }
                                else if(addressList.get(i).toString().equalsIgnoreCase("BON DE COMMANDE")||addressList.get(i).toString().equalsIgnoreCase("BON DE LIVRAISON")) {
                                    //list.add(StringUtils.strTobytes(" "));    //added to add gap between address and bon de livraison
                                    //list.add(StringUtils.strTobytes(" "));    //added to add gap between address and bon de

                                    //list.add(DataForSendToPrinterPos80.selectCharacterSize(9));
                                    byte[] fontSize = {0x1D, 0x21, 0x11};
                                    list.add(fontSize);
                                }
                                else
                                {
                                    list.add(DataForSendToPrinterPos80.selectCharacterSize(10));
                                }
                                if(i==addressList.size()-1)
                                {
                                    //list.add(StringUtils.strTobytes(" "));
                                    //list.add(StringUtils.strTobytes(" "));
                                    //list.add(StringUtils.strTobytes(" "));
                                }
                                list.add(data1);
                                byte[] resetFontSize = {0x1D, 0x21, 0x00};
                                list.add(resetFontSize);
                                //should add the command of print and feed line,because print only when one line is complete, not one line, no print
                                list.add(DataForSendToPrinterPos80.printAndFeedLine());
                            }
                            //list.add(DataForSendToPrinterPos80.selectCharacterSize(9));
                            list.add(DataForSendToPrinterPos80.selectCharacterSize(0));
                            for(int i=0;i<headingList.size();i++)
                            {
                                String data = headingList.get(i).toString();
                                data = addSpaces(data,printSize);
                                byte[] data1= StringUtils.strTobytesSpecialSymbol(data);
                                //list.add(DataForSendToPrinterPos80.selectHRIFont(20));

                                list.add(data1);
                                //should add the command of print and feed line,because print only when one line is complete, not one line, no print
                                list.add(DataForSendToPrinterPos80.printAndFeedLine());
                            }
                            //list.add(DataForSendToPrinterPos80.selectFont(12));
                            byte[] dataline= StringUtils.strTobytes("------------------------------------------------");
                            list.add(dataline);
                            //should add the command of print and feed line,because print only when one line is complete, not one line, no print
                            list.add(DataForSendToPrinterPos80.printAndFeedLine());

                            for(int i=0;i<itemList.size();i++)
                            {
                                String data = itemList.get(i).toString();
                                //byte[] data1= StringUtils.strTobytesSpecialSymbol(data);
                                data = addSpaces(data,printSize);
                                //byte[] data1= StringUtils.strTobytes(data);
                                byte[] data1= StringUtils.strTobytesSpecialSymbol(data);
                                if(data.charAt(0)==' ') { //attributes should not bold
                                    list.add(data1);
                                }
                                else{
                                    list.add(boldStart);
                                    list.add(data1);
                                    list.add(boldEnd);
                                }
                                //should add the command of print and feed line,because print only when one line is complete, not one line, no print
                                list.add(DataForSendToPrinterPos80.printAndFeedLine());
                            }
                            list.add(dataline);
                            //should add the command of print and feed line,because print only when one line is complete, not one line, no print
                            list.add(DataForSendToPrinterPos80.printAndFeedLine());

                            //list.add(DataForSendToPrinterPos80.selectAlignment(5));
                            list.add(DataForSendToPrinterPos80.selectAlignment(0));
                            // list.add(DataForSendToPrinterPos80.selectFont(5));

                            try {
                                if (deliveryFee.equalsIgnoreCase("0") == false) {
                                    String totalFormated = addSpaces(deliveryFee,printSize);
                                    byte[] data1= StringUtils.strTobytesSpecialSymbol(totalFormated);
                                    byte[] euroSign = {0x1B, 0x74,0x13,0x1C,0x2E,(byte)0xD5,0x0A};
                                    byte[] combinedData = ByteBuffer.allocate(data1.length + euroSign.length)
                                            .put(data1)
                                            .put(euroSign)
                                            .array();
                                    //list.add(DataForSendToPrinterPos80.selectCharacterSize(9)); // commented to make same footer and items
                                    list.add(combinedData);
                                }
                            }
                            catch (Exception e)
                            {
                                e.printStackTrace();
                            }

                            try {
                                if (nightFee.equalsIgnoreCase("0") == false) {
                                    String totalFormated = addSpaces(nightFee,printSize);
                                    byte[] data1= StringUtils.strTobytesSpecialSymbol(totalFormated);
                                    byte[] euroSign = {0x1B, 0x74,0x13,0x1C,0x2E,(byte)0xD5,0x0A};
                                    byte[] combinedData = ByteBuffer.allocate(data1.length + euroSign.length)
                                            .put(data1)
                                            .put(euroSign)
                                            .array();
                                    //list.add(DataForSendToPrinterPos80.selectCharacterSize(9)); // commented to make same footer and items
                                    list.add(combinedData);
                                }
                            }
                            catch (Exception e)
                            {
                                e.printStackTrace();
                            }

                            String totalFormated = addSpaces(total,printSize);
                            byte[] data1= StringUtils.strTobytesSpecialSymbol(totalFormated);
                            byte[] euroSign = {0x1B, 0x74,0x13,0x1C,0x2E,(byte)0xD5,0x0A};
                            byte[] combinedData = ByteBuffer.allocate(data1.length + euroSign.length)
                                    .put(data1)
                                    //.put(euroSign)
                                    .array();
                            //list.add(DataForSendToPrinterPos80.selectCharacterSize(9)); // commented to make same footer and items

                            list.add(boldStart); //bold start
                            //byte[] fortSize = {0x1D, 0x21, 0x12};
                            //list.add(fortSize);
                            list.add(DataForSendToPrinterPos80.selectCharacterSize(11));
                            list.add(combinedData);
                            list.add(DataForSendToPrinterPos80.selectCharacterSize(10));
                            list.add(boldEnd); //bold end



                            //should add the command of print and feed line,because print only when one line is complete, not one line, no print
                            list.add(DataForSendToPrinterPos80.printAndFeedLine());


                            for(int i=0;i<footerList.size();i++)
                            {
                                String data = footerList.get(i).toString();
                                data = addSpaces(data,printSize);
                                byte[] data2= StringUtils.strTobytesSpecialSymbol(data);
                                if(data.equalsIgnoreCase("Ce bon n'est pas un justificatif de paiement."))
                                {
                                    list.add(DataForSendToPrinterPos80.selectAlignment(1));
                                }
                                else if(data.equalsIgnoreCase("MODE DE PAIEMENT ATTENDU"))
                                {
                                    list.add(DataForSendToPrinterPos80.selectAlignment(1));
                                }
                                else
                                {
                                    try {
                                        if(footerList.get(i-1).toString().equalsIgnoreCase("MODE DE PAIEMENT ATTENDU"))
                                        {
                                            list.add(DataForSendToPrinterPos80.selectAlignment(1));
                                        }
                                        else
                                        {
                                            list.add(DataForSendToPrinterPos80.selectAlignment(0));
                                        }
                                    }
                                    catch (Exception e)
                                    {
                                        e.printStackTrace();
                                        list.add(DataForSendToPrinterPos80.selectAlignment(0));
                                    }

                                }



                                list.add(data2);
                                //should add the command of print and feed line,because print only when one line is complete, not one line, no print
                                list.add(DataForSendToPrinterPos80.printAndFeedLine());
                            }
                            list.add(DataForSendToPrinterPos80.printAndFeedLine()); //empty lines before cut paper
                            list.add(DataForSendToPrinterPos80.printAndFeedLine());
                            list.add(DataForSendToPrinterPos80.printAndFeedLine());
                            list.add(DataForSendToPrinterPos80.printAndFeedLine());
                            list.add(DataForSendToPrinterPos80.printAndFeedLine());

                            //cut pager
                            //list.add(DataForSendToPrinterPos80.selectCutPagerModerAndCutPager(66,1));
                            byte[] partialCutPaper1 = new byte[]{29, 109};
                            list.add(partialCutPaper1);

                            byte[] partialCutPaper = {0x1B, 0x6D};
                            list.add(partialCutPaper);
                            //list.add(DataForSendToPrinterPos80.selectCutPagerModerAndCutPager(66,printCopies));
                            return list;
                        }
                        return null;
                    }
                });

    }

    private void printOrderNumberTicket(IMyBinder binder, final ArrayList addressList,
                           final String printSize,final String name,final int code){
        //final int printCopies = Integer.parseInt(etPrintCopies.getText().toString());

        /*final ArrayList addressList = (ArrayList<String>) getIntent().getSerializableExtra("address");
        final ArrayList headingList = (ArrayList<String>) getIntent().getSerializableExtra("heading");
        final ArrayList itemList = (ArrayList<String>) getIntent().getSerializableExtra("items");
        final String total = getIntent().getStringExtra("total");
        final ArrayList footerList = (ArrayList<String>) getIntent().getSerializableExtra("footer");*/
        binder.writeDataByYouself(
                new UiExecute() {
                    @Override
                    public void onsucess() {

                    }

                    @Override
                    public void onfailed() {

                    }
                }, new ProcessData() {
                    @Override
                    public List<byte[]> processDataBeforeSend() {

                        List<byte[]> list=new ArrayList<byte[]>();
                        //creat a text ,and make it to byte[],
                        //String str=text.getText().toString();
                        // if (str.equals(null)||str.equals("")){
                        if(false)
                        {
                            //showSnackbar(getString(R.string.text_for));
                        }else {
                            //initialize the printer
//                            list.add( DataForSendToPrinterPos58.initializePrinter());
                            list.add(DataForSendToPrinterPos80.initializePrinter());
                            //list.add(DataForSendToPrinterPos80.selectCharacterCodePage(1252));
                            //DataForSendToPrinterPos80.setCharsetName("ibm00858");
                            list.add(DataForSendToPrinterPos80.selectCharacterCodePage(code));
                            //DataForSendToPrinterPos80.setCharsetName("Cp858");
                            DataForSendToPrinterPos80.setCharsetName(name);
                            list.add(DataForSendToPrinterPos80.selectCharacterSize(10));
                            for(int i=0;i<addressList.size();i++)
                            {
                                list.add(DataForSendToPrinterPos80.selectCharacterSize(10));
                                String data = addressList.get(i).toString();
                                if(data.contains("TEL :")==false) {
                                    data = addSpaces(data,printSize);
                                }
                                byte[] data1= StringUtils.strTobytesSpecialSymbol(data);
                                list.add(DataForSendToPrinterPos80.selectAlignment(1));
                                if(addressList.get(i).toString().contains("N° "))
                                {
                                    //list.add(DataForSendToPrinterPos80.selectCharacterSize(27));
                                    int iHeight = 8;
                                    int iWidth = 8;
                                    int iSize = iHeight + iWidth * 0x10;

                                    //byte[] dat = {0x1D, 0x21,(byte) iSize};
                                    byte[] dat = {0x1D, 0x21, 0x23};

                                    //list.add(DataForSendToPrinterPos80.selectCharacterSize(iSize));
                                    list.add(dat);
                                }
                                else if(addressList.get(i).toString().equalsIgnoreCase("BON DE COMMANDE")||addressList.get(i).toString().equalsIgnoreCase("BON DE LIVRAISON")) {
                                    //list.add(StringUtils.strTobytes(" "));    //added to add gap between address and bon de livraison
                                    //list.add(StringUtils.strTobytes(" "));    //added to add gap between address and bon de livraison
                                    list.add(DataForSendToPrinterPos80.selectCharacterSize(10));
                                }
                                else
                                {
                                    list.add(DataForSendToPrinterPos80.selectCharacterSize(10));
                                    //continue;
                                }
                                if(i==addressList.size()-1)
                                {
                                    list.add(StringUtils.strTobytes(" "));
                                    list.add(StringUtils.strTobytes(" "));
                                    list.add(StringUtils.strTobytes(" "));
                                }
                                list.add(data1);
                                //should add the command of print and feed line,because print only when one line is complete, not one line, no print
                                list.add(DataForSendToPrinterPos80.printAndFeedLine());
                            }
                            //list.add(DataForSendToPrinterPos80.selectCharacterSize(9));
                            list.add(StringUtils.strTobytes(" "));
                            list.add(StringUtils.strTobytesSpecialSymbol("Merci pour votre commande!"));
                            list.add(StringUtils.strTobytes(" "));
                            list.add(StringUtils.strTobytes(" "));
                            list.add(StringUtils.strTobytes(" "));
                            list.add(DataForSendToPrinterPos80.selectCharacterSize(0));



                                        //should add the command of print and feed line,because print only when one line is complete, not one line, no print
                            list.add(DataForSendToPrinterPos80.printAndFeedLine());
                            list.add(DataForSendToPrinterPos80.printAndFeedLine());
                            list.add(DataForSendToPrinterPos80.printAndFeedLine());
                            list.add(DataForSendToPrinterPos80.printAndFeedLine());
                            list.add(DataForSendToPrinterPos80.printAndFeedLine());

                            //cut pager
                            //list.add(DataForSendToPrinterPos80.selectCutPagerModerAndCutPager(66,1));
                            byte[] partialCutPaper = {0x1B, 0x6D};
                            list.add(partialCutPaper);
                            //list.add(DataForSendToPrinterPos80.selectCutPagerModerAndCutPager(66,printCopies));
                            return list;
                        }
                        return null;
                    }
                });

    }

    public void printTestMessage(IMyBinder binder, final String messsage){
        binder.writeDataByYouself(
                new UiExecute() {
                    @Override
                    public void onsucess() {

                    }

                    @Override
                    public void onfailed() {

                    }
                }, new ProcessData() {
                    @Override
                    public List<byte[]> processDataBeforeSend() {

                        List<byte[]> list=new ArrayList<byte[]>();
                        //creat a text ,and make it to byte[],
                        //String str=text.getText().toString();
                        // if (str.equals(null)||str.equals("")){
                        if(false)
                        {
                            //showSnackbar(getString(R.string.text_for));
                        }else {
                            //initialize the printer
//                            list.add( DataForSendToPrinterPos58.initializePrinter());
                            list.add(DataForSendToPrinterPos80.initializePrinter());

                            list.add(DataForSendToPrinterPos80.selectCharacterSize(10));

                            //list.add(DataForSendToPrinterPos80.selectCharacterSize(9));
                            list.add(StringUtils.strTobytes(messsage));
                            list.add(StringUtils.strTobytes(" "));
                            list.add(StringUtils.strTobytes(" "));
                            list.add(StringUtils.strTobytes(" "));
                            //list.add(StringUtils.strTobytesSpecialSymbol("Merci pour votre commande!"));
                            list.add(DataForSendToPrinterPos80.selectCharacterSize(0));



                            //should add the command of print and feed line,because print only when one line is complete, not one line, no print
                            list.add(DataForSendToPrinterPos80.printAndFeedLine());
                            list.add(DataForSendToPrinterPos80.printAndFeedLine());
                            list.add(DataForSendToPrinterPos80.printAndFeedLine());
                            list.add(DataForSendToPrinterPos80.printAndFeedLine());
                            list.add(DataForSendToPrinterPos80.printAndFeedLine());

                            //cut pager
                            //list.add(DataForSendToPrinterPos80.selectCutPagerModerAndCutPager(66,1));
                            byte[] partialCutPaper = {0x1B, 0x6D};
                            list.add(partialCutPaper);
                            //list.add(DataForSendToPrinterPos80.selectCutPagerModerAndCutPager(66,printCopies));
                            return list;
                        }
                        return null;
                    }
                });

    }


    private String addSpaces(String itemWithCaption,String printSize)
    {
        int size = 45;
        if(printSize!=null&&printSize.equals("58mm"))
        {
            size = 31;
        }
        if(itemWithCaption.contains(":")) {
            String space = "   ";
            int l = itemWithCaption.length();
            if (l < size) {
                for (int x = size - l; x >= 0; x--) {
                    space = space + " ";
                }
            }
            itemWithCaption = itemWithCaption.replace(" : ", space);

        }
        if(itemWithCaption.contains("("))
        {
            String space = "   ";
            int l = itemWithCaption.length();
            if (l < size) {
                for (int x = size - l; x >= 0; x--) {
                    space = space + " ";
                }
            }
            itemWithCaption = itemWithCaption+space;

        }
        return itemWithCaption;
    }
}
