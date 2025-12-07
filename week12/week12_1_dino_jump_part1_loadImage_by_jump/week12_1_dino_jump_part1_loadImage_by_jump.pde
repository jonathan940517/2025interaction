//week12-1_dino_jump_part1_loadImage_by_jump
PImage img;
void setup(){
  size(300,500);
  img=loadImage("cutedino.jpg");
  
}
float x=200,y=400,dx=0,dy=0;
void draw(){
  background(255);
  image(img,x,y,100,100);
  y+=dy;
  if(y<400)dy+=0.98;
  else dy=0;
}
void keyPressed(){
  if(keyCode==UP) dy=-15;
}
