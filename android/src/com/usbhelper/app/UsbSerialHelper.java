package com.usbhelper.app;

import android.app.Activity;
import android.content.Context;
import android.hardware.usb.UsbDevice;
import android.hardware.usb.UsbDeviceConnection;
import android.hardware.usb.UsbManager;
import android.os.ParcelFileDescriptor;
import android.util.Log;
import org.qtproject.qt.android.QtNative;
import java.util.HashMap;

public class UsbSerialHelper {
    private static final String TAG = "UsbSerialHelper";

    public int openDevice() {
        // Grab the native Qt Activity Context automatically
        Activity currentActivity = QtNative.activity();
        if (currentActivity == null) {
            Log.e(TAG, "Failed to get Qt Activity Context.");
            return -1;
        }

        UsbManager usbManager = (UsbManager) currentActivity.getSystemService(Context.USB_SERVICE);
        HashMap<String, UsbDevice> deviceList = usbManager.getDeviceList();
        UsbDevice targetDevice = null;

        // Common ESP32/Arduino VIDs
        int[] validVids = {4292, 6790, 1027, 12346};

        for (UsbDevice device : deviceList.values()) {
            for (int vid : validVids) {
                if (device.getVendorId() == vid) {
                    targetDevice = device;
                    break;
                }
            }
            if (targetDevice != null) break;
        }

        if (targetDevice == null) {
            Log.w(TAG, "No compatible ESP32 board found via USB.");
            return -1;
        }

        // Check if permissions are already granted
        if (!usbManager.hasPermission(targetDevice)) {
            Log.w(TAG, "USB Permission missing. OS should trigger dialog now.");
            // Note: In production environments, invoke usbManager.requestPermission() here
            return -1;
        }

        // Open connection and extract native File Descriptor
        UsbDeviceConnection connection = usbManager.openDevice(targetDevice);
        if (connection != null) {
            int fd = connection.getFileDescriptor();
            Log.i(TAG, "Success! Opened USB device. Native FD: " + fd);
            return fd;
        }

        Log.e(TAG, "Failed to open connection to USB device.");
        return -1;
    }
}