// week10_6_arduino_serial_joystick_x_y_to_processing
void setup() {
  Serial.begin(9600); 
  pinMode(2, INPUT_PULLUP);
  pinMode(8, OUTPUT); 
}

void loop() { 
  delay(30); 
  int x = analogRead(A2); 
  int y = analogRead(A3);
  Serial.write(x/4); 
  Serial.write(y/4); 
  if(x>900) tone(8, 784, 100); 
  if(x<100) tone(8, 523, 100);
  if(y>900) tone(8, 659, 100);
  if(y<100) tone(8, 500, 100); 
}
