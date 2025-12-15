class Bomb{
  int gx,gy;
  int startTime;
  boolean playerLeft = false;
}
class Fire{
  int gx,gy;
  int startTime;
}
class Enemy {
  int gx, gy;        
  int dir;           
  int moveTime;      
  boolean alive = true;

  
  int startTime;     
  int startGX, startGY; 
  int targetGX, targetGY;
  boolean moving = false;

  Enemy(int gx, int gy) {
    this.gx = gx;
    this.gy = gy;
    pickRandomDir();
    moveTime = millis() + 300;
  }

  void pickRandomDir() {
    dir = int(random(4));
  }

  void update() {
    if (!alive) return;


    if (moving) {
      float t = (millis() - startTime) / 300.0;
      if (t >= 1) {
        gx = targetGX;
        gy = targetGY;
        moving = false;
      }
      return;
    }

    if (millis() < moveTime) return;
    moveTime = millis() + 300;

    pickRandomDir();
    int nx = gx;
    int ny = gy;
    
    if (dir == 0) nx++;
    if (dir == 1) nx--;
    if (dir == 2) ny++;
    if (dir == 3) ny--;

    if (nx < 0 || nx >= 20 || ny < 0 || ny >= 20 || walls[nx][ny] != 0) {
      pickRandomDir();
      return;
    }

    startTime = millis();
    startGX = gx;
    startGY = gy;
    targetGX = nx;
    targetGY = ny;
    moving = true;
  }

  void show() {
    if (!alive) return;

    float px = gx * 30 + 15;
    float py = gy * 30 + 15;

    if (moving) {
      float t = (millis() - startTime) / 300.0;
      t = constrain(t, 0, 1);
      px = lerp(startGX * 30 + 15, targetGX * 30 + 15, t);
      py = lerp(startGY * 30 + 15, targetGY * 30 + 15, t);
    }

    fill(0, 255, 255);
    ellipse(px, py, 22, 22);
  }
}

int PlayerX,PlayerY,dx=0,dy=0,BlockX,BlockY;
ArrayList<Bomb>bombs = new ArrayList<Bomb>();
ArrayList<Fire>fires = new ArrayList<Fire>();
ArrayList<Enemy>enemies = new ArrayList<Enemy>();
int [][] walls = {  
  {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, 
  {0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0},
  {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0},
  {0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0}, 
  {0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, 
  {0, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0}, 
  {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, 
  {0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0},
  {0, 0, 0, 0, 0, 0, 0, 0, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3}, 
  {0, 1, 1, 1, 1, 1, 1, 0, 3, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0}, 
  {0, 1, 1, 1, 1, 1, 1, 0, 3, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0}, 
  {0, 1, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, 
  {0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0}, 
  {0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
  {0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0}, 
  {0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
  {0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0}, 
  {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, 
  {0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0}, 
  {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
};
void checkplayerleave(){
  int pgx=PlayerX/30;
  int pgy=PlayerY/30;
  for(Bomb b:bombs){
    if(b.gx!=pgx||b.gy!=pgy)b.playerLeft=true;
  }
}
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
void showfires(){
  //noStroke();
  fill(255, 150, 0, 180);
  for(Fire f:fires){
    rect(f.gx*30,f.gy*30,30,30);
  }
}
void updateFires(){
  for(int i=fires.size()-1;i>=0;i--){
    Fire f = fires.get(i);
    if(millis()-f.startTime>=200){
      fires.remove(i);
    }
  }
  int PlayerGx = PlayerX/30;
  int PlayerGy = PlayerY/30;
  for(Fire f:fires){
    if(f.gx==PlayerGx&&f.gy==PlayerGy){
      println("GameOver");
      noLoop();
    }
  }
  for(Enemy e:enemies){
    if(!e.alive)continue;
    for(Fire f:fires){
      if(e.gx==f.gx&&e.gy==f.gy){
        e.alive=false;
      }
    }
  }
}
int r=2;
void explode(int gx,int gy){
  walls[gx][gy] = 0;
  int [][]dir = {{1,0},{0,1},{-1,0},{0,-1}};
    for(int[]d:dir){
      for(int i=0;i<=r;i++){
        Fire f=new Fire();
        int nx=gx+d[0]*i;
        int ny=gy+d[1]*i;
        if(nx < 0 || nx >= 20 || ny < 0 || ny >= 20) break;
        if(walls[nx][ny]==1)break;
        f.gx=nx;
        f.gy=ny;
        f.startTime=millis();
        fires.add(f);
        if(walls[nx][ny]==3){
          walls[nx][ny]=0;
          break;
        }
      }
    }
}


void setup(){
  size(600,600);
  PlayerX=300;
  PlayerY=300;
  enemies.add(new Enemy(5, 5));
  enemies.add(new Enemy(10, 8));
}
void draw(){
  BlockX=(PlayerX+dx)/30;
  BlockY=(PlayerY+dy)/30;
  checkplayerleave();
  updateBombs();
  updateFires();
  for (Enemy e : enemies) e.update();
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
       if(walls[i][j]==3){
        fill(255,0,255);
        rect(i*30, j*30, 30, 30);
       }
      }
     }
   showfires();
   boolean canmove=false;
  if(PlayerX+dx>=0&&PlayerX+dx<=599&&PlayerY+dy>=0&&PlayerY+dy<=599&&walls[BlockX][BlockY]==0){
        canmove=true;
  }
  for(Bomb b:bombs){
    if(b.gx==BlockX&&b.gy==BlockY&&b.playerLeft==false)canmove=true;
  }
  if(canmove){
    PlayerX+=dx;
    PlayerY+=dy;
  }
  for (Enemy e : enemies) e.show();
  fill(255,255,0);
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
