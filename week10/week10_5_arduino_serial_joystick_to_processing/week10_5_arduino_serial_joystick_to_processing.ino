// week10_5_arduino_serial_joystick_to_processing
void setup() {
  Serial.begin(9600); 
  pinMode(2, INPUT_PULLUP);
  pinMode(8, OUTPUT); 
}

void loop() { 
  delay(30); 
  int now = analogRead(A3) / 4;
  Serial.write(now); 
  if(now > 200) tone(8, 784, 100); 
  if( now < 50) tone(8, 532, 100);
}