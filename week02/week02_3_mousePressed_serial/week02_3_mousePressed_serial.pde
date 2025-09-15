//week02_3_mousePressed_serial
import processing.serial.*;
Serial myPort;
void mousePressed(){
  myPort.write(' ');
}
void setup(){
  size(400,400);
  myPort = new Serial(this,"COM4",9600);
}
void draw(){
  if(mousePressed)background(#FF0000);
  else background(#00FF00);
}
