void setup() {
  Serial.begin(9600);
  pinMode(2, INPUT_PULLUP);  // 搖桿按鈕，接 D2
}
void loop() {
  delay(30); // 要慢一點, 不然 Processing 會接不了
  int x = analogRead(A2); // 0~1023
  int y = analogRead(A3); // 0~1023
  int btnRaw = digitalRead(2);  // INPUT_PULLUP: 放開=HIGH, 按下=LOW
  // 座標壓到 0~255
  int bx = x / 4;
  int by = y / 4;
  // 按鈕：按下=1，沒按=0
  int bbtn = (btnRaw == LOW) ? 1 : 0;
  // 依序送出 3 個 byte：X, Y, Button
  Serial.write(bx);
  Serial.write(by);
  Serial.write(bbtn);
  // Serial.print("x=");
  // Serial.print(bx);
  // Serial.print(",y=");
  // Serial.print(by);
  // Serial.print(",bbtn=");
  // Serial.print(bbtn);
  // Serial.println();
}
