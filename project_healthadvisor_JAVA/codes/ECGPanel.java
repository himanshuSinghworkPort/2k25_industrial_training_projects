package com.example.ecgmonitor;

import javax.swing.*;
import java.awt.*;
import java.util.List;

public class ECGPanel extends JPanel {
    private List<Double> data = List.of();

    /** Update the panel’s data (called from app timer). */
    public void setData(List<Double> buf) {
        data = buf;
        repaint();
    }

    @Override
    protected void paintComponent(Graphics g) {
        super.paintComponent(g);
        if (data.isEmpty()) return;

        int w = getWidth(), h = getHeight();
        double min = data.stream().mapToDouble(d -> d).min().orElse(0);
        double max = data.stream().mapToDouble(d -> d).max().orElse(1);

        int len = data.size();
        for (int i = 1; i < len; i++) {
            int x1 = (i - 1) * w / len;
            int y1 = h - (int) ((data.get(i - 1) - min) / (max - min) * h);
            int x2 = i * w / len;
            int y2 = h - (int) ((data.get(i) - min) / (max - min) * h);
            g.drawLine(x1, y1, x2, y2);
        }
    }
}
