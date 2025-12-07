//week12-4_dino_jump_many_boards
PImage img;
void setup(){
  size(300,500);
  img=loadImage("cutedino.jpg");
}
float []boardX={50,200,100,200};
float []boardY={100,200,300,400};
float x=200,y=400,dx=0,dy=0;
boolean flying=false;
void draw(){
  background(255);
  boolean flying=true;
  for(int i=0;i<4;i++){
    rect(boardX[i],boardY[i],100,5);
    if(y+100<=boardY[i] && y+dy+100>=boardY[i] && boardX[i]<=x+100 && x<=boardX[i]+100){
    y=boardY[i]-100;
    dy=0;
    flying=false;
    } 
  }
  if(flying){
     y+=dy;
     if(y<400)dy+=0.98;
     else{
       dy=0;
       flying=false;
     }
  }
  image(img,x,y,100,100);
  x+=dx;
}
void keyPressed(){
  if(keyCode==UP) dy=-15;
  if(keyCode==LEFT) dx=-1;
  if(keyCode==RIGHT) dx=+1;
}
void keyReleased(){
  if(keyCode==LEFT || keyCode==RIGHT) dx=0;
}
