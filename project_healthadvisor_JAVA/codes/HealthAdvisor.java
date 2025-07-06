package com.example.ecgmonitor;

public class HealthAdvisor {
    public String getAdvice(int bpm) {
        if (bpm == 0) {
            return "Collecting data…";
        } else if (bpm < 60) {
            return "Bradycardia (<60 BPM). Consider light activity or consult a doctor if persistent.";
        } else if (bpm <= 100) {
            return "Normal heart rate (60–100 BPM). Keep up hydration and good sleep.";
        } else {
            return "Tachycardia (>100 BPM). Try relaxation; see a physician if it continues.";
        }
    }
}
