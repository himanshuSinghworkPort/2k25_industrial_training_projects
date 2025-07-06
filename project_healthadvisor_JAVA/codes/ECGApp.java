package com.example.ecgmonitor;

import com.fazecast.jSerialComm.SerialPort;
import javax.swing.*;
import java.awt.*;
import java.awt.event.*;
import java.io.FileWriter;
import java.io.PrintWriter;
import java.util.List;
import java.util.*;
import java.util.Timer;

public class ECGApp extends JFrame implements SerialReader.DataListener {
    // Core components
    private final SignalProcessor processor  = new SignalProcessor();
    private final HealthAdvisor advisor     = new HealthAdvisor();
    private final ECGPanel ecgPanel         = new ECGPanel();
    private final JLabel bpmLabel           = new JLabel("BPM: --", SwingConstants.CENTER);
    private final JTextArea adviceArea      = new JTextArea(3,20);

    // New controls
    private final JComboBox<String> portList     = new JComboBox<>();
    private final JButton      btnRefresh        = new JButton("Refresh");
    private final JButton      btnConnect        = new JButton("Connect");
    private final JButton      btnDisconnect     = new JButton("Disconnect");
    private final JButton      btnStart          = new JButton("Start");
    private final JButton      btnStop           = new JButton("Stop");
    private final JButton      btnCalibrate      = new JButton("Calibrate");
    private final JButton      btnSaveCSV        = new JButton("Save CSV");
    
    private SerialReader reader;
    private Timer       uiTimer;
    private boolean     monitoring = false;

    public ECGApp() {
        super("ECG Monitor");
        setDefaultCloseOperation(EXIT_ON_CLOSE);
        setSize(900, 650);
        setLayout(new BorderLayout());
        
        // --- TOP CONTROL PANEL ---
        JPanel top = new JPanel(new FlowLayout(FlowLayout.LEFT, 5, 5));
        top.add(new JLabel("Port:"));
        top.add(portList);
        top.add(btnRefresh);
        top.add(btnConnect);
        top.add(btnDisconnect);
        top.add(btnStart);
        top.add(btnStop);
        top.add(btnCalibrate);
        top.add(btnSaveCSV);
        add(top, BorderLayout.NORTH);
        
        // --- CENTER ECG TRACE ---
        add(ecgPanel, BorderLayout.CENTER);

        // --- BOTTOM INFO PANEL ---
        JPanel bottom = new JPanel(new BorderLayout(5,5));
        bpmLabel.setFont(new Font("Monospaced", Font.BOLD, 24));
        bottom.add(bpmLabel, BorderLayout.NORTH);
        adviceArea.setLineWrap(true);
        adviceArea.setWrapStyleWord(true);
        adviceArea.setEditable(false);
        bottom.add(new JScrollPane(adviceArea), BorderLayout.CENTER);
        add(bottom, BorderLayout.SOUTH);

        // Initialize components
        adviceArea.setText("Connect your Arduino to begin.");
        btnDisconnect.setEnabled(false);
        btnStart.setEnabled(false);
        btnStop.setEnabled(false);

        // Populate ports & wire actions
        refreshPorts();
        btnRefresh.addActionListener(e -> refreshPorts());
        btnConnect.addActionListener(e -> connectPort());
        btnDisconnect.addActionListener(e -> disconnectPort());
        btnStart.addActionListener(e -> startMonitoring());
        btnStop.addActionListener(e -> stopMonitoring());
        btnCalibrate.addActionListener(e -> calibrateThreshold());
        btnSaveCSV.addActionListener(e -> saveToCSV());

        setVisible(true);
    }

    /** 1) Refresh available COM ports */
    private void refreshPorts() {
        portList.removeAllItems();
        for (SerialPort sp : SerialPort.getCommPorts()) {
            portList.addItem(sp.getSystemPortName());
        }
    }

    /** 2) Connect to the selected port */
    private void connectPort() {
        String portName = (String)portList.getSelectedItem();
        if (portName == null) return;
        try {
            reader = new SerialReader(portName, this);
            adviceArea.setText("Connected to " + portName);
            btnConnect.setEnabled(false);
            btnDisconnect.setEnabled(true);
            btnStart.setEnabled(true);
        } catch (Exception ex) {
            JOptionPane.showMessageDialog(this, "Error opening port: "+ex.getMessage());
        }
    }

    /** 3) Disconnect safely */
    private void disconnectPort() {
        stopMonitoring();
        if (reader != null) {
            reader.close();
            reader = null;
        }
        adviceArea.setText("Disconnected.");
        btnConnect.setEnabled(true);
        btnDisconnect.setEnabled(false);
        btnStart.setEnabled(false);
        btnStop.setEnabled(false);
    }

    /** 4) Start the UI update timer & processing */
    private void startMonitoring() {
        if (monitoring) return;
        monitoring = true;
        btnStart.setEnabled(false);
        btnStop.setEnabled(true);
        // UI refresh every 500ms
        uiTimer = new Timer(true);
        uiTimer.scheduleAtFixedRate(new java.util.TimerTask() {
            @Override public void run() {
                int bpm = processor.computeBPM();
                SwingUtilities.invokeLater(() -> {
                    bpmLabel.setText("BPM: " + bpm);
                    adviceArea.setText(advisor.getAdvice(bpm));
                    ecgPanel.setData(processor.getBuffer());
                });
            }
        }, 0, 500);
    }

    /** 5) Stop monitoring */
    private void stopMonitoring() {
        if (!monitoring) return;
        monitoring = false;
        btnStart.setEnabled(true);
        btnStop.setEnabled(false);
        if (uiTimer != null) uiTimer.cancel();
    }

    /** 6) Threshold calibration routine */
    private void calibrateThreshold() {
        // Simple approach: sample 3 seconds of data at rest
        List<Double> snapshot = processor.getBuffer();
        double max = snapshot.stream().mapToDouble(d->d).max().orElse(1.0);
        processor.setThreshold(0.7 * max);  // expose this in SignalProcessor
        JOptionPane.showMessageDialog(this, 
          String.format("Calibrated threshold to %.3f V", processor.getThreshold()));
    }

    /** 7) Export the current buffer to CSV */
    private void saveToCSV() {
        JFileChooser chooser = new JFileChooser();
        if (chooser.showSaveDialog(this) != JFileChooser.APPROVE_OPTION) return;
        try (PrintWriter out = new PrintWriter(new FileWriter(chooser.getSelectedFile()))) {
            out.println("timestamp,voltage");
            long now = System.currentTimeMillis();
            List<Double> data = processor.getBuffer();
            for (int i=0; i<data.size(); i++) {
                long ts = now - (data.size()-i)*(1000/250);
                out.printf("%d,%.3f%n", ts, data.get(i));
            }
            JOptionPane.showMessageDialog(this, "Saved " + data.size() + " samples.");
        } catch (Exception ex) {
            JOptionPane.showMessageDialog(this, "Error saving CSV: "+ex.getMessage());
        }
    }

    /** SerialReader callback: feed into processor */
    @Override
    public void onData(double voltage) {
        double filtered = processor.bandpass(voltage);
        processor.addSample(filtered);
    }

    @Override
    public void dispose() {
        super.dispose();
        stopMonitoring();
        if (reader != null) reader.close();
    }

    public static void main(String[] args) {
        SwingUtilities.invokeLater(ECGApp::new);
    }
}
