package com.example.ecgmonitor;

import com.fazecast.jSerialComm.*;

public class SerialReader {
    public interface DataListener {
        void onData(double voltage);
    }

    private final SerialPort port;

    public SerialReader(String portDescriptor, DataListener listener) {
        port = SerialPort.getCommPort(portDescriptor);
        port.setBaudRate(115200);
        if (!port.openPort()) {
            throw new IllegalStateException("Failed to open serial port " + portDescriptor);
        }

        port.addDataListener(new SerialPortDataListener() {
            @Override public int getListeningEvents() {
                return SerialPort.LISTENING_EVENT_DATA_AVAILABLE;
            }
            @Override public void serialEvent(SerialPortEvent event) {
                if (event.getEventType() != SerialPort.LISTENING_EVENT_DATA_AVAILABLE)
                    return;
                byte[] buffer = new byte[port.bytesAvailable()];
                int numRead = port.readBytes(buffer, buffer.length);
                if (numRead > 0) {
                    String s = new String(buffer).trim();
                    for (String token : s.split("\\r?\\n")) {
                        try {
                            double v = Double.parseDouble(token);
                            listener.onData(v);
                        } catch (NumberFormatException ignored) {}
                    }
                }
            }
        });
    }

    public void close() {
        port.closePort();
    }
}
