// ecg_sender.ino
// Reads analog ECG on A0 and streams voltage over serial at ~250Hz.

const int ECG_PIN = A0;

void setup() {
  Serial.begin(115200);
  pinMode(ECG_PIN, INPUT);
}

void loop() {
  int raw = analogRead(ECG_PIN);         // 0–1023
  float voltage = raw * (5.0 / 1023.0);  // Convert to volts
  Serial.println(voltage, 3);            // e.g. "1.234"
  delay(4);                              // ~250 samples/sec
}
