package com.example.ecgmonitor;

import java.util.LinkedList;
import java.util.List;

/**
 * Pan–Tompkins ECG signal processor:
 *  1) Band-pass via integer-based LP & HP filters
 *  2) Derivative to emphasize slopes
 *  3) Squaring to make all data positive and accentuate large differences
 *  4) Moving-window integration to smooth
 *  5) Peak detection on the integrated signal for BPM
 */
public class SignalProcessor {
    private static final int FS = 250;                  // sampling frequency
    private static final int MAX_SAMPLES = FS * 5;      // 5s buffer

    // Buffers for each stage
    private final LinkedList<Double> rawBuffer  = new LinkedList<>();
    private final LinkedList<Double> lpBuffer   = new LinkedList<>();
    private final LinkedList<Double> hpBuffer   = new LinkedList<>();
    private final LinkedList<Double> diffBuffer = new LinkedList<>();
    private final LinkedList<Double> sqrBuffer  = new LinkedList<>();
    private final LinkedList<Double> intBuffer  = new LinkedList<>();

    private double thresholdFraction = 0.5; // fraction of peak for peak detection

    /** Add a new raw sample and push it through the full pipeline */
    public synchronized void addSample(double v) {
        // 1) Buffer raw
        rawBuffer.add(v);
        if (rawBuffer.size() > MAX_SAMPLES) rawBuffer.removeFirst();

        // 2) Low-pass filter
        double lp = applyLowPass(v);
        lpBuffer.add(lp);
        if (lpBuffer.size() > MAX_SAMPLES) lpBuffer.removeFirst();

        // 3) High-pass filter
        double hp = applyHighPass(lp);
        hpBuffer.add(hp);
        if (hpBuffer.size() > MAX_SAMPLES) hpBuffer.removeFirst();

        // 4) Derivative
        double der = derivative(hp);
        diffBuffer.add(der);
        if (diffBuffer.size() > MAX_SAMPLES) diffBuffer.removeFirst();

        // 5) Squaring
        double sq = der * der;
        sqrBuffer.add(sq);
        if (sqrBuffer.size() > MAX_SAMPLES) sqrBuffer.removeFirst();

        // 6) Moving-window integration (~120 ms window)
        double integ = movingWindowIntegration();
        intBuffer.add(integ);
        if (intBuffer.size() > MAX_SAMPLES) intBuffer.removeFirst();
    }

    /** Get a snapshot of the integrated signal (for plotting or analysis) */
    public synchronized List<Double> getIntegratedBuffer() {
        return List.copyOf(intBuffer);
    }

    /** Estimate BPM by counting peaks in the integrated signal */
    public synchronized int computeBPM() {
        int n = intBuffer.size();
        if (n < FS / 2) return 0;  // need at least 0.5s of data

        // 1) Find max to set threshold
        double max = intBuffer.stream().mapToDouble(d -> d).max().orElse(1.0);
        double thresh = thresholdFraction * max;

        // 2) Count local maxima above threshold
        int count = 0;
        for (int i = 1; i < n - 1; i++) {
            double prev = intBuffer.get(i - 1),
                   curr = intBuffer.get(i),
                   next = intBuffer.get(i + 1);
            if (curr > thresh && curr > prev && curr > next) {
                count++;
                // skip ahead ~200 ms to avoid double-counting
                i += FS / 5;
            }
        }

        // 3) Convert to BPM
        double windowSec = n / (double) FS;
        return (int) Math.round((count / windowSec) * 60.0);
    }

    /** Set detection threshold as a fraction of signal peak (0.0–1.0) */
    public void setThresholdFraction(double frac) {
        this.thresholdFraction = frac;
    }

    /** @return current threshold fraction */
    public double getThresholdFraction() {
        return thresholdFraction;
    }

    // ─── INTERNAL FILTER & TRANSFORM STAGES ──────────────────────────────────────

    /** 1) Low-pass: y[n]=2y[n−1]−y[n−2]+x[n]−2x[n−6]+x[n−12] */
    private double applyLowPass(double x0) {
        int i = rawBuffer.size() - 1;
        double x6  = i >= 6  ? rawBuffer.get(i - 6)  : 0.0;
        double x12 = i >= 12 ? rawBuffer.get(i - 12) : 0.0;
        double y1  = lpBuffer.size() > 0  ? lpBuffer.getLast()        : 0.0;
        double y2  = lpBuffer.size() > 1  ? lpBuffer.get(lpBuffer.size() - 2) : 0.0;
        return 2*y1 - y2 + x0 - 2*x6 + x12;
    }

    /** 2) High-pass: y[n]=y[n−1]−x[n]/32+x[n−16]−x[n−17]+x[n−32]/32 */
    private double applyHighPass(double x0) {
        int i = lpBuffer.size() - 1;
        double x16 = i >= 16 ? lpBuffer.get(i - 16) : 0.0;
        double x17 = i >= 17 ? lpBuffer.get(i - 17) : 0.0;
        double x32 = i >= 32 ? lpBuffer.get(i - 32) : 0.0;
        double y1  = hpBuffer.size() > 0 ? hpBuffer.getLast() : 0.0;
        return y1 - x0/32.0 + x16 - x17 + x32/32.0;
    }

    /** 3) Derivative: y[n]=(1/8)(2x[n]+x[n−1]−x[n−3]−2x[n−4]) */
    private double derivative(double x0) {
        int i = hpBuffer.size() - 1;
        double x1 = i >= 1  ? hpBuffer.get(i - 1) : 0.0;
        double x3 = i >= 3  ? hpBuffer.get(i - 3) : 0.0;
        double x4 = i >= 4  ? hpBuffer.get(i - 4) : 0.0;
        return (2*x0 + x1 - x3 - 2*x4) / 8.0;
    }

    /** 4) Moving-window integration over ~120 ms (window = FS*0.12) */
    private double movingWindowIntegration() {
        int window = (int)(FS * 0.12);
        double sum = 0.0;
        int size = sqrBuffer.size();
        for (int i = Math.max(0, size - window); i < size; i++) {
            sum += sqrBuffer.get(i);
        }
        return window > 0 ? sum / window : 0.0;
    }
}
