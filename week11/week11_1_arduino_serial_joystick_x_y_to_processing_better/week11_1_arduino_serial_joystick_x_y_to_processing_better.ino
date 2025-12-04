// week11_1_arduino_serial_joystick_x_y_to_processing_better
void setup() {
  Serial.begin(9600);
  pinMode(2, INPUT_PULLUP);
  pinMode(8, OUTPUT); 
} 
int count=0, totalX = 0, totalY=0;
int x0 = 512, y0 = 512;
void loop() { 
  delay(30); 
  int x = analogRead(A2); 
  int y = analogRead(A3);
  if (count<20){  
    totalX += x;
    totalY += y; 
    count++; 
  x0 = totalX / count;  
  y0 = totalY / count;
  }
  if( abs(x-x0)<25 ) x = 128;  
  else x = (x-x0)/4.4 + 128;  
  if( abs(y-y0)<25 ) y = 128;  
  else x = (y-y0)/4.4 + 128; 
  Serial.write(x);
  Serial.write(y);
}