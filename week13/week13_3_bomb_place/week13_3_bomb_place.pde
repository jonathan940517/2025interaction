class Bomb{
  int gx,gy;
  int startTime;
}
int PlayerX,PlayerY,dx=0,dy=0,BlockX,BlockY;
ArrayList<Bomb>bombs = new ArrayList<Bomb>();
int [][] walls = {  
  {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, 
  {0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0},
  {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0},
  {0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0}, 
  {0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, 
  {0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0}, 
  {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, 
  {0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0},
  {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, 
  {0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0}, 
  {0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0}, 
  {0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, 
  {0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0}, 
  {0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
  {0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0}, 
  {0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
  {0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0}, 
  {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, 
  {0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0}, 
  {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
};
void placebomb(){
  Bomb b = new Bomb();
  b.gx=PlayerX/30;
  b.gy=PlayerY/30;
  b.startTime = millis();
  walls[b.gx][b.gy]=2;
  bombs.add(b);
}
void updateBombs(){
  for(int i=bombs.size()-1;i>=0;i--){
    Bomb b = bombs.get(i);
    if(millis()-b.startTime>=2000){
      explode(b.gx,b.gy);
      bombs.remove(i);
    }
  }
}
void explode(int gx,int gy){
  walls[gx][gy] = 0;
  int [][]dir = {{1,0},{0,1},{-1,0},{0,-1}};
  for(int[]d:dir){
    int nx=gx+d[0];
    int ny=gy+d[1];
    if(nx>=0&&nx<20&&ny>=0&&ny<20){
      walls[nx][ny]=0;
    }
  }
}
void setup(){
  size(600,600);
  PlayerX=300;
  PlayerY=300;
}
void draw(){
  BlockX=(PlayerX+dx)/30;
  BlockY=(PlayerY+dy)/30;
  updateBombs();
  background(150);
  for(int i=0; i<20; i++){  
    for(int j=0; j<20; j++){ 
      if(walls[i][j]==1){
        fill(255);
        rect(i*30, j*30, 30, 30);
       }
       if(walls[i][j]==2){
        fill(255,255,0);
        rect(i*30, j*30, 30, 30);
       }
      }
     }
  if(PlayerX+dx>=0&&PlayerX+dx<=599&&PlayerY+dy>=0&&PlayerY+dy<=599&&walls[BlockX][BlockY]!=1){
        PlayerX+=dx;
        PlayerY+=dy;
  }
  ellipse(PlayerX,PlayerY,8,8);
}
void keyPressed(){
  if(keyCode==LEFT)dx=-1;
  if(keyCode==RIGHT)dx=1;
  if(keyCode==UP)dy=-1;
  if(keyCode==DOWN)dy=1;
  if(keyCode==' ')placebomb();
}
void keyReleased(){
  if(keyCode==LEFT)dx=0;
  if(keyCode==RIGHT)dx=0;
  if(keyCode==UP)dy=0;
  if(keyCode==DOWN)dy=0;
}
