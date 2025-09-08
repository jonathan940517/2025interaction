void setup(){
  size(500,500);
}
int x=200,y=250;
void draw(){
  background(#FFFFAA);
  if(mousePressed&&x<mouseX&&x+100>mouseX&&y<mouseY&&y+50>mouseY){
    x += mouseX - pmouseX;
    y += mouseY - pmouseY;
  }
  rect(x,y,100,50);
}
