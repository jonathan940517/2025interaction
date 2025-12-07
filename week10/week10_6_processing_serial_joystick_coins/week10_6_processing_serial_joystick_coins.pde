// week10_6_processing_serial_joystick_coins
import processing.serial.*;
Serial myPort;
void setup(){
  size(500, 500);
  myPort = new Serial(this, "COM5", 9600);
  rectMode(CENTER); 
}
int x = 250, y = 400, now;
float dx = 0; 
void draw(){
  background(#FFFFA0);
  rect(x, y, 100, 20);
  if ( myPort.available() > 0 ){
    now = myPort.read();
    dx = (now-127)/10.0; 
    if(abs(dx)<0.21) dx = 0; 
  }
  x += dx;
}
