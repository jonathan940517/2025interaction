//week11_6_pacman_part5_wall
void setup() {
  size(600, 600); 
}
int x=300-15, y=300-15, dx=0, dy=0, dir=0; 
float m=0, dm=0.05; 
boolean[][] bean_eaten=new boolean[20][20]; 
void draw() {
  background(0);
  for (int i=0; i<20; i++) {
    for (int j=0; j<20; j++) {
      if (bean_eaten[i][j]==false) {
        fill(255); 
        ellipse(15+j*30, 15+i*30, 5, 5);
        if (dist(x, y, 15+j*30, 15+i*30)<15) bean_eaten[i][j]=true;
      }
    }
  }
  fill(255,255,0); 
  float m0 = dir*PI/2;  
  arc(x,y,30,30,m0+m,m0+PI*2-m); 
  if(x+dx>=15 && x+dx <=600-15) x+=dx; 
  if(y+dy>=15 && y+dy <=600-15) y+=dy;
  if((x-15)%30==0 && (y-15)%30==0){
    if(next==2) {dx=-1;dy=0;dir=2;}  
    if(next==0) {dx=+1;dy=0;dir=0;}  
    if(next==3) {dx=0;dy=0-1;dir=3;} 
    if(next==1) {dx=0;dy=+1;dir=1;} 
    next=-1; 
  }
  if(m>=1 || m<0) dm=-dm;
  m+=dm;
}
  int next=-1;  
  void keyPressed() {
    if (keyCode==LEFT) next=2;
    if (keyCode==RIGHT) next=0;
    if (keyCode==UP) next=3;
    if (keyCode==DOWN) next=1;
  
}
