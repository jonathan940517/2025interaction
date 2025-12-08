int PlayerX,PlayerY,dx=0,dy=0;
void setup(){
  size(300,300);
  PlayerX=150;
  PlayerY=150;
}
void draw(){
  background(150);
  PlayerX+=dx;
  PlayerY+=dy;
  ellipse(PlayerX,PlayerY,8,8);
}
void keyPressed(){
  if(keyCode==LEFT)dx=-1;
  if(keyCode==RIGHT)dx=1;
  if(keyCode==UP)dy=-1;
  if(keyCode==DOWN)dy=1;
}
void keyReleased(){
  if(keyCode==LEFT)dx=0;
  if(keyCode==RIGHT)dx=0;
  if(keyCode==UP)dy=0;
  if(keyCode==DOWN)dy=0;
}
