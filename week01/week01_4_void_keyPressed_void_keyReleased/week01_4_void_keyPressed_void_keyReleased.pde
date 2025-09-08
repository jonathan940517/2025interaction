void setup(){
  size(500,500);
}
int x=200,y=250,dx=0,dy=0;
void draw(){
  background(#FFFFAA);
  rect(x,y,100,50);
  x+=dx;
  y+=dy;
}
void keyPressed(){
  if(keyCode==LEFT)dx-=3;
  if(keyCode==RIGHT)dx+=3;
  if(keyCode==UP)dy=-3;
  if(keyCode==DOWN)dy+=3;
}
void keyReleased(){
  if(keyCode==LEFT)dx=0;
  if(keyCode==RIGHT)dx=0;
  if(keyCode==UP)dy=0;
  if(keyCode==DOWN)dy=0;
}
