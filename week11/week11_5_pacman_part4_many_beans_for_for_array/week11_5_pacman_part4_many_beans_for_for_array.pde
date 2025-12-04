// week11_5_pacman_part4_many_beans_for_for_array
void setup(){
  size(600, 600); 
}
int x = 300-15, y= 300-15, dx=0, dy=0, dir=0; 
float m=0, dm=0.05;  
boolean [][] bean_eaten = new boolean[20][20]; 
void draw(){
  background(0);
  for(int i=0; i<20; i++){
    for(int j=0; j<20; j++){
      if( bean_eaten[i][j]==false ){
        fill(255);  
        ellipse( 15+j*30, 15+i*30, 5, 5);
        if( dist(x,y, 15+j*30, 15+i*30) <=15) bean_eaten[i][j]=true;
      }
    }
  }
  fill(255, 255, 0); 
  float m0=dir*PI/2;  
  arc(x, y, 30, 30, m0+m, m0+PI*2-m); 
  x += dx; 
  y += dy; 
  if( m>=1 || m<0 ) dm = -dm; 
  m += dm;
}
void keyPressed(){
  if(keyCode==LEFT)   { dx=-1; dy=0; dir=2;} 
  if(keyCode==RIGHT)  { dx=+1; dy=0; dir=0;} 
  if(keyCode==UP)     { dx=0; dy=-1; dir=3;} 
  if(keyCode==DOWN)   { dx=0; dy=+1; dir=1;} 
}
