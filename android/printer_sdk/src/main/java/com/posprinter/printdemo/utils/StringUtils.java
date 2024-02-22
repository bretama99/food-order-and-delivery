package com.posprinter.printdemo.utils;

import java.io.UnsupportedEncodingException;

/**
 * Created by kylin on 2017/4/6.
 */

public class StringUtils {
    /**
     * string to byte[]
     * */
    public static byte[] strTobytes(String str){
        byte[] b=null,data=null;
        try {
            b = str.getBytes("utf-8");
            data=new String(b,"utf-8").getBytes("gbk");
        } catch (UnsupportedEncodingException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        return data;
    }

    public static byte[] strTobytesSpecialSymbol(String str){
        byte[] b=null,data=null,finalData = null;
       /* str.replaceAll("à","$");
        str.replaceAll("ç","@");
        str.replaceAll("é","#");
        str.replaceAll("ù","&");
        str.replaceAll("è","!");*/

        for(int i=0;i<str.length();i++) {
            try {
                char ch = str.charAt(i);
                char ch1 = ' ';
                try{
                    ch1 = str.charAt(i+1);
                }
                catch (Exception e)
                {
                    e.printStackTrace();
                }
                //b = str.getBytes("utf-8");
                if((ch+"").equals("€"))
                {
                    //data = new byte[]{0x1B, 0x74,0x13,0x1C,0x2E,(byte)0xD5,0x0A};
                    data = new byte[]{0x1B, 0x74,0x13,0x1C,0x2E,(byte)0xD5};
                }
                //else if((ch+"").equals("à"))
                else if((ch+""+ch1).equals("à"))
                {
                    data = new byte[]{0x1B, 0x52,0x01,(byte)0x85}; //1B 74 00 40
                    i++;
                }
                else if((ch+"").equals("à"))
                {
                    data = new byte[]{0x1B, 0x52,0x01,(byte)0x85};
                }
                //else if((ch+"").equals("â"))
                else if((ch+""+ch1).equals("â"))
                {
                    data = new byte[]{0x1B, 0x52,0x01,(byte)0x83}; //1B 52 01 40
                    i++;
                }
                else if((ch+"").equals("â"))
                {
                    data = new byte[]{0x1B, 0x52,0x01,(byte)0x83}; //1B 52 01 40
                }
                else if((ch+"").equals("°"))
                {
                    data = new byte[]{0x1B, 0x52,0x01,(byte)0x5B};
                }
                else if((ch+"").equals("§"))
                {
                    data = new byte[]{0x1B, 0x52,0x01,(byte)0x5D};
                }
                else if((ch+"").equals("^"))
                {
                    data = new byte[]{0x1B, 0x52,0x01,(byte)0x5E};
                }
                //else if((ch+"").equals("Ç"))
                else if((ch+""+ch1).equals("Ç"))
                {
                    data = new byte[]{0x1B, 0x52,0x01,(byte)0x80};
                    i++;
                }
                else if((ch+"").equals("Ç"))
                {
                    data = new byte[]{0x1B, 0x52,0x01,(byte)0x80};
                }
                //else if((ch+"").equals("ç"))
                else if((ch+""+ch1).equals("ç"))
                {
                    data = new byte[]{0x1B, 0x52,0x01,(byte)0x87}; //or 5C
                    i++;
                }
                else if((ch+"").equals("ç"))
                {
                    data = new byte[]{0x1B, 0x52,0x01,(byte)0x87}; //or 5C
                }
                //else if((ch+"").equals("É"))
                else if((ch+""+ch1).equals("É"))
                {
                    data = new byte[]{0x1B, 0x52,0x01,(byte)0x90};
                    i++;
                }
                else if((ch+"").equals("É"))
                {
                    data = new byte[]{0x1B, 0x52,0x01,(byte)0x90};
                }
                //else if((ch+"").equals("é"))
                else if((ch+""+ch1).equals("é"))
                {
                    data = new byte[]{0x1B, 0x52,0x01,(byte)0x82}; //7B
                    i++;
                }
                else if((ch+"").equals("é"))
                {
                    data = new byte[]{0x1B, 0x52,0x01,(byte)0x82}; //7B
                }
                //else if((ch+"").equals("è"))
                else if((ch+""+ch1).equals("è"))
                {
                    data = new byte[]{0x1B, 0x52,0x01,(byte)0x8A}; //7D
                    i++;
                }
                else if((ch+"").equals("è"))
                {
                    data = new byte[]{0x1B, 0x52,0x01,(byte)0x8A}; //7D
                }
                //else if((ch+"").equals("ê"))
                else if((ch+""+ch1).equals("ê"))
                {
                    data = new byte[]{0x1B, 0x52,0x01,(byte)0x88};
                    i++;
                }
                else if((ch+"").equals("ê"))
                {
                    data = new byte[]{0x1B, 0x52,0x01,(byte)0x88};
                }
                //else if((ch+"").equals("ë"))
                else if((ch+""+ch1).equals("ë"))
                {
                    data = new byte[]{0x1B, 0x52,0x01,(byte)0x89};
                    i++;
                }
                else if((ch+"").equals("ë"))
                {
                    data = new byte[]{0x1B, 0x52,0x01,(byte)0x89};
                }
                //else if((ch+"").equals("ù"))
                else if((ch+""+ch1).equals("ù"))
                {
                    data = new byte[]{0x1B, 0x52,0x01,(byte)0x97}; // 7C
                    i++;
                }
                else if((ch+"").equals("ù"))
                {
                    data = new byte[]{0x1B, 0x52,0x01,(byte)0x97}; // 7C
                }
                //else if((ch+"").equals("ï"))
                else if((ch+""+ch1).equals("ï"))
                {
                    data = new byte[]{0x1B, 0x52,0x01,(byte)0x8B};
                    i++;
                }
                else if((ch+"").equals("ï"))
                {
                    data = new byte[]{0x1B, 0x52,0x01,(byte)0x8B};
                }
                //else if((ch+"").equals("î"))
                else if((ch+""+ch1).equals("î"))
                {
                    data = new byte[]{0x1B, 0x52,0x01,(byte)0x8C};
                    i++;
                }
                else if((ch+"").equals("î"))
                {
                    data = new byte[]{0x1B, 0x52,0x01,(byte)0x8C};
                }
                //else if((ch+"").equals("ô"))
                else if((ch+""+ch1).equals("ô"))
                {
                    data = new byte[]{0x1B, 0x52,0x01,(byte)0x93};
                    i++;
                }
                else if((ch+"").equals("ô"))
                {
                    data = new byte[]{0x1B, 0x52,0x01,(byte)0x93};
                }
                else {
                    b = (ch + "").getBytes("utf-8");
                    data = new String(b, "utf-8").getBytes("gbk");
                }
                if (finalData == null) {
                    finalData = data;
                } else {
                    finalData = byteMerger(finalData, data);
                }
            } catch (UnsupportedEncodingException e) {
                // TODO Auto-generated catch block
                e.printStackTrace();
            }
        }
        return finalData;
    }
    

    /**
     * byte[] merger
     * */
    public static   byte[] byteMerger(byte[] byte_1, byte[] byte_2){
        byte[] byte_3 = new byte[byte_1.length+byte_2.length];
        System.arraycopy(byte_1, 0, byte_3, 0, byte_1.length);
        System.arraycopy(byte_2, 0, byte_3, byte_1.length, byte_2.length);
        return byte_3;
    }
    public static byte[] strTobytes(String str ,String charset){
        byte[] b=null,data=null;
        try {
            b = str.getBytes("utf-8");
            data=new String(b,"utf-8").getBytes(charset);
        } catch (UnsupportedEncodingException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        return data;
    }
}
