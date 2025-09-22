import processing.serial.*;
Serial myPort;
void setup(){
  size(400,400);
  myPort = new Serial(this,"COM6",9600);
}
void mousePressed(){
  myPort.write('b');
}

void draw(){
  if(mousePressed)background(#FF0000);
  else background(#00FF00);
}
