// week10_3_arduino_analogRead_A3
void setup() {
  pinMode(2, INPUT_PULLUP);
  pinMode(8, OUTPUT); 
}

void loop() {
  int now = analogRead(A3);
  if(now > 800){ 
    tone(8, 532, 100);
    delay(100);
    tone(8, 784, 100); 
    delay(100); 
  }else if( now < 200){ 
    tone(8, 784, 100); 
    delay(100);
    tone(8, 532, 100);
    delay(100);
  }
}
