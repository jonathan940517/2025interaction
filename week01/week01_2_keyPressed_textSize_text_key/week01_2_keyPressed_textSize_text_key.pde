void setup(){
  size(500,500);
}
void draw(){
  if(keyPressed){
    background(#FF0000);
    textSize(80);
    text(""+key,100,100);
  }
}
