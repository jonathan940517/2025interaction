// week10_4_arduino_serial_Monitor_joystick_Serial_println
void setup() {
  Serial.begin(9600); 
  pinMode(2, INPUT_PULLUP);
  pinMode(8, OUTPUT); 
}

void loop() { 
  delay(100); 
  int now = analogRead(A3); 
  Serial.println(now);
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
