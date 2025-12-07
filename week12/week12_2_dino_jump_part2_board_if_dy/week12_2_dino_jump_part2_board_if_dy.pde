//week12-2_dino_jump_part2_board_if_dy
PImage img;
void setup(){
  size(300,500);
  img=loadImage("cutedino.jpg");
}
float boardX=200,boardY=400;
float x=200,y=400,dx=0,dy=0;
void draw(){
  background(255);
  rect(boardX,boardY,100,5);
  image(img,x,y,100,100);
  if(y+100<=boardY && y+dy+x>=boardY){
    y=boardY-100;
    dy=0;
  }else{
    y+=dy;
    if(y<400) dy+=0.98;
    else dy=0;
  } 
}
void keyPressed(){
  if(keyCode==UP) dy=-15;
}
