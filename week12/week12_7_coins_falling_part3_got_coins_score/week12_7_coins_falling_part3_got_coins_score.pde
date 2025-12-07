//week12-7_coins_falling_part3_got_coins_score
PImage imgCoin;
void setup(){
  size(300,500);
  imgCoin=loadImage("coin.jpg");
  for(int i=0;i<10;i++){
    x[i]=random(300-100);
    y[i]=-100-random(1000);
  }
}
float userX=150,userY=450;
float []x=new float[10];
float []y=new float[10];
int score=0,dx=0;
void draw(){
  userX+=dx;
  background(255);
  fill(255);
  for(int i=0;i<10;i++){
    rect(x[i]-1,y[i]-1,102,102);
    image(imgCoin,x[i],y[i],100,100);
    y[i]+=3;
    if(dist(userX,userY,x[i]+50,y[i]+50)<50){
      score+=100;
      x[i]=random(300-100);
      y[i]=-100-random(200);
    }
    if(y[i]>500){
      x[i]=random(300-100);
      y[i]=-100-random(200);
    }
  }
  fill(255,0,0);
  ellipse(userX,userY,50,10);
  fill(0);
  text("Score: "+score,200,50);
}
void keyPressed(){
  if(keyCode==LEFT)dx=-1;
  if(keyCode==RIGHT)dx=1;
}
