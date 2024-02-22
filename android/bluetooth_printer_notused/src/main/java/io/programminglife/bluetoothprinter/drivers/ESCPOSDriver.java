package io.programminglife.bluetoothprinter.drivers;

import android.util.Log;

import java.io.BufferedOutputStream;
import java.io.IOException;
import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;

/**
 * Created by andreivisan on 10/28/15.
 */
public class ESCPOSDriver {

    private static String tag = ESCPOSDriver.class.getSimpleName();

    private static final byte[] LINE_FEED = {0x0A};
    private static final byte[] PAPER_FEED = {27, 0x4A, (byte)0xFF};
   // private static final byte[] PAPER_CUT = {0x1D, 0x56, 0x10};
    //private static final byte[] PAPER_CUT = {0x1D, 0x56, 0x41, 0x10};
    private static final byte[] PAPER_CUT = {0x1D, 0x56, 66, 0x00};
    private static final byte[] ALIGN_LEFT = {0x1B, 0x61, 0};
    private static final byte[] ALIGN_CENTER = {0x1B, 0x61, 1};
    private static final byte[] ALIGN_RIGHT = {0x1B, 0x61, 2};
    private static final byte[] BOLD_ON = {0x1B, 0x45, 1};
    private static final byte[] BOLD_OFF = {0x1B, 0x45, 0};
    private static final byte[] INIT = {0x1B, 0x40};
    private static final byte[] STANDARD_MODE = {0x1B, 0x53};
    private static final byte[] SWITCH_COMMAND = {0x1B, 0x69, 0x61, 0x00};
    private static final byte[] FLUSH_COMMAND = {(byte)0xFF, 0x0C};

    public void initPrint(BufferedOutputStream bufferedOutputStream) {
        try {
            bufferedOutputStream.write(SWITCH_COMMAND);
            bufferedOutputStream.write(INIT);
        } catch (IOException e) {
            Log.e(tag, e.getMessage(), e);
        }
    }

    public void printLineAlignLeft(BufferedOutputStream bufferedOutputStream, String lineData) {
        try {
            bufferedOutputStream.write(ALIGN_LEFT);
            bufferedOutputStream.write(lineData.getBytes());
            bufferedOutputStream.write(LINE_FEED);
        } catch (IOException e) {
            Log.e(tag, e.getMessage(), e);
        }
    }

    public void printLineAlignCenter(BufferedOutputStream bufferedOutputStream, String lineData) {
        try {
            bufferedOutputStream.write(ALIGN_CENTER);
            //bufferedOutputStream.write(lineData.getBytes());
            bufferedOutputStream.write(lineData.getBytes(Charset.forName("Cp858")));
            bufferedOutputStream.write(LINE_FEED);
        } catch (IOException e) {
            Log.e(tag, e.getMessage(), e);
        }
    }

    public void printLineAlignRight(BufferedOutputStream bufferedOutputStream, String lineData) {
        try {
            bufferedOutputStream.write(ALIGN_RIGHT);
            bufferedOutputStream.write(lineData.getBytes());
            bufferedOutputStream.write(LINE_FEED);
        } catch (IOException e) {
            Log.e(tag, e.getMessage(), e);
        }
    }

    public void boldOn(BufferedOutputStream bufferedOutputStream)
    {
        try
        {
            bufferedOutputStream.write(BOLD_ON);
        }
        catch (IOException e)
        {
            e.printStackTrace();
        }
    }
    public void boldOff(BufferedOutputStream bufferedOutputStream)
    {
        try
        {
            bufferedOutputStream.write(BOLD_OFF);
        }
        catch (IOException e)
        {
            e.printStackTrace();
        }
    }

    public void addItem(BufferedOutputStream bufferedOutputStream,String itemWithCaption,boolean singleCenter,int spaces)
    {
        spaces = 31;
        try {
            if(itemWithCaption.contains(":")) {
                //bufferedOutputStream.write(ALIGN_RIGHT);
                bufferedOutputStream.write(ALIGN_LEFT);
                String space = "   ";
                int l = itemWithCaption.length();
                if (l < spaces) {
                    for (int x = spaces - l; x >= 0; x--) {
                        space = space + " ";
                    }
                }
                itemWithCaption = itemWithCaption.replace(" : ", space);
            }
            else
            {
                if(singleCenter) {
                    bufferedOutputStream.write(ALIGN_CENTER);
                }
                else {
                    //bufferedOutputStream.write(ALIGN_LEFT);
                    bufferedOutputStream.write(ALIGN_RIGHT);
                }
            }

            //bufferedOutputStream.write(itemWithCaption.getBytes());
            bufferedOutputStream.write(itemWithCaption.getBytes(Charset.forName("Cp858")));
            bufferedOutputStream.write(LINE_FEED);
        } catch (IOException e) {
            Log.e(tag, e.getMessage(), e);
        }
    }

    public void nextLine(BufferedOutputStream bufferedOutputStream)
    {
        try {
            bufferedOutputStream.write(LINE_FEED);
        }
        catch (Exception e)
        {
            e.printStackTrace();
        }
    }
    public void finishPrint(BufferedOutputStream bufferedOutputStream) {
        try {
            bufferedOutputStream.write(PAPER_FEED);
            bufferedOutputStream.write(PAPER_CUT);
        } catch (IOException e) {
            Log.e(tag, e.getMessage(), e);
        }
    }

    public void flushCommand(BufferedOutputStream bufferedOutputStream) {
        try {
            //String pound = "\u00a3";
            //String euro = "€";
            //byte[] b1 = pound.getBytes(Charset.forName("Cp858"));

            //byte[] b2 = pound.getBytes(StandardCharsets.Cp858);

          //  bufferedOutputStream.write(b1);
            //bufferedOutputStream.write(b2);

            bufferedOutputStream.write(FLUSH_COMMAND);
            bufferedOutputStream.write(PAPER_FEED);
            bufferedOutputStream.write(PAPER_CUT);
        } catch (IOException e) {
            Log.e(tag, e.getMessage(), e);
        }
    }

}
