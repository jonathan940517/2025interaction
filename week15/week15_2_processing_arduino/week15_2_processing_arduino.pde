import processing.serial.*;   // ★ 使用序列埠
Serial myPort;                // ★ Serial 物件

// Joystick 讀到的值 (0~255)
int joyX = 128;
int joyY = 128;
// Joystick 按鈕狀態
int joyBtn = 0;       // 現在這一幀的按鈕 (0/1)
int joyBtnPrev = 0;   // 上一幀的按鈕 (用來抓「按下瞬間」)

// =============================
//      遊戲設定區（之後只改這裡就好）
// =============================
final int COLS = 15;          // 地圖寬幾格
final int ROWS = 13;          // 地圖高幾格
final int TILE = 50;          // 每一格像素大小

final int SCREEN_W = COLS * TILE;
final int SCREEN_H = ROWS * TILE;

// 玩家
final float PLAYER_BASE_SPEED = 2.5;   // 初始玩家速度（每 frame 移動多少 pixel）
final float PLAYER_MAX_SPEED  = 6.0;   // 玩家速度上限

// 炸彈 & 火焰
final int MAX_BOMBS_START   = 1;      // 初始可同時放幾顆炸彈
final int BOMB_FUSE_TIME    = 2000;   // 炸彈引信時間（毫秒）
final int FIRE_DURATION     = 200;    // 火焰維持時間（毫秒）
final int BOMB_BASE_RANGE   = 1;      // 初始爆炸範圍（不算中心，往外幾格）

// 怪物
final int   ENEMY_MOVE_INTERVAL = 500;   // 怪物移動一格所需時間（毫秒）
final float ENEMY_CHASE_CHANCE  = 0.4;   // 40% 機率朝玩家方向走

// 遊戲狀態
final int STATE_PLAYING   = 0;
final int STATE_GAME_OVER = 1;
final int STATE_WIN       = 2;
int gameState = STATE_PLAYING;

// =============================
//          貼圖宣告
// =============================
PImage imgFloor;
PImage imgWall;
PImage imgSoftWall;
PImage imgPlayer;
PImage imgEnemy;
PImage imgBomb;
PImage imgFire;
PImage imgItemBomb;
PImage imgItemSpeed;
PImage imgItemPower;   // ★ 增加爆炸範圍

// 預先做好「小尺寸」貼圖（避免每幀縮放）
PImage imgPlayerSmall;
PImage imgEnemySmall;
PImage imgItemBombSmall;
PImage imgItemSpeedSmall;
PImage imgItemPowerSmall;


// ----------------------
//       CLASS: Bomb
// ----------------------
class Bomb {
  int gx, gy;
  int startTime;
  boolean playerLeft = false;
}

// ----------------------
//       CLASS: Fire
// ----------------------
class Fire {
  int gx, gy;
  int startTime;
}

// ----------------------
//     CLASS: Enemy
// ----------------------
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
    chooseDirection();
    moveTime = millis() + ENEMY_MOVE_INTERVAL;
  }

  void chooseDirection() {
    int playerGX = PlayerX / TILE;
    int playerGY = PlayerY / TILE;

    // --- 有機率朝玩家方向走 ---
    if (random(1) < ENEMY_CHASE_CHANCE) {
      int dx = playerGX - gx;
      int dy = playerGY - gy;

      if (abs(dx) > abs(dy)) {
        if (dx > 0) dir = 0;   // 右
        else        dir = 1;   // 左
      } else {
        if (dy > 0) dir = 2;   // 下
        else        dir = 3;   // 上
      }
      return;
    }

    // 其餘情況隨機
    dir = int(random(4));
  }

  void update() {
    if (!alive) return;

    // 動畫中就只做插值
    if (moving) {
      float t = (millis() - startTime) / float(ENEMY_MOVE_INTERVAL);
      if (t >= 1) {
        gx = targetGX;
        gy = targetGY;
        moving = false;
      } else {
        t = constrain(t, 0, 1);
        return;
      }
    }

    if (millis() < moveTime) return;
    moveTime = millis() + ENEMY_MOVE_INTERVAL;

    chooseDirection();

    int nx = gx;
    int ny = gy;

    if (dir == 0) nx++;
    if (dir == 1) nx--;
    if (dir == 2) ny++;
    if (dir == 3) ny--;

    if (nx < 0 || nx >= COLS || ny < 0 || ny >= ROWS || walls[nx][ny] != 0) {
      // 撞牆就這回合不動，下一回合再選方向
      return;
    }

    startGX = gx;
    startGY = gy;
    targetGX = nx;
    targetGY = ny;
    startTime = millis();
    moving = true;
  }

  void show() {
    if (!alive) return;

    float px = gx * TILE + TILE/2;
    float py = gy * TILE + TILE/2;

    if (moving) {
      float t = (millis() - startTime) / float(ENEMY_MOVE_INTERVAL);
      t = constrain(t, 0, 1);
      float sx = startGX * TILE + TILE/2;
      float sy = startGY * TILE + TILE/2;
      float tx = targetGX * TILE + TILE/2;
      float ty = targetGY * TILE + TILE/2;
      px = lerp(sx, tx, t);
      py = lerp(sy, ty, t);
    }

    imageMode(CENTER);
    if (imgEnemySmall != null) {
      image(imgEnemySmall, px, py);
    } else if (imgEnemy != null) {
      image(imgEnemy, px, py);
    } else {
      fill(0, 255, 255);
      ellipse(px, py, TILE * 0.7, TILE * 0.7);
    }
    imageMode(CORNER);
  }
}


// ---------------------------------------------------
//                    GLOBALS
// ---------------------------------------------------
int PlayerX, PlayerY;
int dx = 0, dy = 0;
float playerSpeed = PLAYER_BASE_SPEED;

int maxBombs = MAX_BOMBS_START;
int r = BOMB_BASE_RANGE;  // 爆炸範圍（不算中心）

ArrayList<Bomb> bombs = new ArrayList<Bomb>();
ArrayList<Fire> fires = new ArrayList<Fire>();
ArrayList<Enemy> enemies = new ArrayList<Enemy>();

int[][] items = new int[COLS][ROWS]; // 1=炸彈 2=範圍 3=速度

// 地圖
int[][] walls = {
  {0,0,0,0,0,0,3,0,0,0,0,0,0},
  {0,1,1,1,3,1,3,1,3,1,1,1,0},
  {0,1,0,0,0,3,0,0,0,0,0,1,0},
  {0,1,0,1,3,1,0,1,3,1,0,1,0},
  {0,3,3,0,3,3,0,1,3,0,3,3,0},
  {0,1,0,0,0,1,0,1,0,0,0,1,0},
  {0,3,3,0,3,3,0,3,3,0,3,3,0},
  {0,1,0,1,0,1,0,1,0,1,0,1,0},
  {0,3,3,0,3,3,0,3,3,0,3,3,0},
  {0,1,0,0,0,1,0,1,0,0,0,1,0},
  {0,3,3,0,3,1,0,3,3,0,3,3,0},
  {0,1,0,1,3,1,0,1,3,1,0,1,0},
  {0,1,0,0,0,0,0,3,0,0,0,1,0},
  {0,1,1,1,3,1,3,1,3,1,1,1,0},
  {0,0,0,0,0,0,3,0,0,0,0,0,0},
};


// ---------------------------------------------------
//                    GAME LOGIC
// ---------------------------------------------------

void checkplayerleave() {
  int pgx = PlayerX / TILE;
  int pgy = PlayerY / TILE;
  for (Bomb b : bombs)
    if (b.gx != pgx || b.gy != pgy)
      b.playerLeft = true;
}

void placebomb() {
  if (gameState != STATE_PLAYING) return;
  if (bombs.size() >= maxBombs) return;

  int gx = PlayerX / TILE;
  int gy = PlayerY / TILE;

  if (gx < 0 || gx >= COLS || gy < 0 || gy >= ROWS) return;

  Bomb b = new Bomb();
  b.gx = gx;
  b.gy = gy;
  b.startTime = millis();
  walls[b.gx][b.gy] = 2;
  bombs.add(b);
}

void updateBombs() {
  for (int i = bombs.size()-1; i >= 0; i--) {
    Bomb b = bombs.get(i);
    if (millis() - b.startTime >= BOMB_FUSE_TIME) {
      explode(b.gx, b.gy);
      bombs.remove(i);
    }
  }
}

void showfires() {
  imageMode(CORNER);
  for (Fire f : fires) {
    float px = f.gx * TILE;
    float py = f.gy * TILE;
    if (imgFire != null) {
      image(imgFire, px, py);
    } else {
      fill(255,150,0,180);
      rect(px, py, TILE, TILE);
    }
  }
}

void updateFires() {
  for (int i=fires.size()-1; i>=0; i--) {
    Fire f = fires.get(i);
    if (millis() - f.startTime >= FIRE_DURATION)
      fires.remove(i);
  }

  int pgx = PlayerX / TILE;
  int pgy = PlayerY / TILE;

  // 火碰到玩家 → GameOver
  if (gameState == STATE_PLAYING) {
    for (Fire f : fires)
      if (f.gx == pgx && f.gy == pgy) {
        gameState = STATE_GAME_OVER;
      }
  }

  // 火碰到敵人 → 敵人死亡
  for (Enemy e : enemies)
    if (e.alive)
      for (Fire f : fires)
        if (e.gx == f.gx && e.gy == f.gy)
          e.alive = false;
}

void explode(int gx, int gy) {
  walls[gx][gy] = 0;

  int[][] dir = {{1,0},{-1,0},{0,1},{0,-1}};

  for (int[] d : dir) {
    for (int i=0; i<=r; i++) {
      int nx = gx + d[0]*i;
      int ny = gy + d[1]*i;

      if (nx < 0 || nx >= COLS || ny < 0 || ny >= ROWS) break;
      if (walls[nx][ny] == 1) break;  // 硬牆阻擋

      Fire f = new Fire();
      f.gx = nx;
      f.gy = ny;
      f.startTime = millis();
      fires.add(f);

      if (walls[nx][ny] == 3) { // 軟牆被炸掉
        walls[nx][ny] = 0;
        maybeSpawnItem(nx, ny);
        break;
      }
    }
  }
}

void maybeSpawnItem(int gx, int gy){
  if (random(1) < 0.5) {  
    float t = random(1);
    if (t < 0.33)      items[gx][gy] = 1;   // 炸彈+1
    else if (t < 0.66) items[gx][gy] = 2;   // 範圍+1
    else               items[gx][gy] = 3;   // 速度+
  }
}

void showItems(){
  imageMode(CENTER);
  for (int x=0;x<COLS;x++)
    for (int y=0;y<ROWS;y++){
      if (items[x][y] == 0) continue;

      float px = x*TILE + TILE/2;
      float py = y*TILE + TILE/2;

      if (items[x][y] == 1) {          // 炸彈+1
        if (imgItemBombSmall != null) {
          image(imgItemBombSmall, px, py);
        } else if (imgItemBomb != null) {
          image(imgItemBomb, px, py);
        } else {
          fill(0,255,0);
          ellipse(px, py, TILE*0.6, TILE*0.6);
        }
      }
      else if (items[x][y] == 2) {     // 範圍+1
        if (imgItemPowerSmall != null) {
          image(imgItemPowerSmall, px, py);
        } else if (imgItemPower != null) {
          image(imgItemPower, px, py);
        } else {
          fill(0,0,255);
          ellipse(px, py, TILE*0.6, TILE*0.6);
        }
      }
      else if (items[x][y] == 3) {     // 速度+
        if (imgItemSpeedSmall != null) {
          image(imgItemSpeedSmall, px, py);
        } else if (imgItemSpeed != null) {
          image(imgItemSpeed, px, py);
        } else {
          fill(255,165,0);
          ellipse(px, py, TILE*0.6, TILE*0.6);
        }
      }
    }
  imageMode(CORNER);
}

void pickupItems(){
  int pgx = PlayerX / TILE;
  int pgy = PlayerY / TILE;

  if (pgx < 0 || pgx >= COLS || pgy < 0 || pgy >= ROWS) return;  // 安全檢查

  int item = items[pgx][pgy];
  if (item == 0) return;

  if (item == 1) {
    maxBombs++;
  }
  if (item == 2) {
    r++;
  }
  if (item == 3) {
    playerSpeed = min(playerSpeed + 0.5, PLAYER_MAX_SPEED);
  }

  items[pgx][pgy] = 0;
}

void checkEnemyHitPlayer(){
  if (gameState != STATE_PLAYING) return;

  int pgx = PlayerX / TILE;
  int pgy = PlayerY / TILE;

  for (Enemy e : enemies)
    if (e.alive && e.gx == pgx && e.gy == pgy) {
      gameState = STATE_GAME_OVER;
    }
}

void checkWin() {
  if (gameState != STATE_PLAYING) return;

  boolean anyAlive = false;
  for (Enemy e : enemies) {
    if (e.alive) {
      anyAlive = true;
      break;
    }
  }
  if (!anyAlive) {
    gameState = STATE_WIN;
  }
}

void drawHUD() {
  // 上方狀態列
  fill(255);
  textAlign(LEFT, TOP);
  textSize(18);
  text("Bombs: " + maxBombs +
       "   Range: " + r +
       "   Speed: " + nf(playerSpeed, 1, 1), 10, 10);

  // 額外顯示 joystick debug
  text("joyX=" + joyX + " joyY=" + joyY + " btn=" + joyBtn, 10, 32);

  // 遊戲結束／勝利 時畫半透明黑底 + 字
  if (gameState == STATE_GAME_OVER || gameState == STATE_WIN) {
    fill(0, 0, 0, 150);
    noStroke();
    rect(0, 0, width, height);

    textAlign(CENTER, CENTER);

    if (gameState == STATE_GAME_OVER) {
      fill(255, 80, 80);
      textSize(40);
      text("GAME OVER", width/2, height/2 - 20);
      noLoop();
    } else if (gameState == STATE_WIN) {
      fill(80, 255, 80);
      textSize(40);
      text("YOU WIN!", width/2, height/2 - 20);
      noLoop();
    }
  }
}

// -----------------------------
//         繪製地圖＋角色
// -----------------------------
void drawMap() {
  imageMode(CORNER);
  for (int x=0;x<COLS;x++) {
    for (int y=0;y<ROWS;y++) {
      float px = x * TILE;
      float py = y * TILE;

      // 地板
      if (imgFloor != null) {
        image(imgFloor, px, py);
      } else {
        fill(150);
        rect(px, py, TILE, TILE);
      }

      // 牆 & 軟牆 & 炸彈
      if (walls[x][y] == 1) {           // 硬牆
        if (imgWall != null) image(imgWall, px, py);
        else {
          fill(200);
          rect(px, py, TILE, TILE);
        }
      }
      else if (walls[x][y] == 3) {      // 軟牆
        if (imgSoftWall != null) image(imgSoftWall, px, py);
        else {
          fill(255,0,255);
          rect(px, py, TILE, TILE);
        }
      }
      else if (walls[x][y] == 2) {      // 炸彈
        if (imgBomb != null) image(imgBomb, px, py);
        else {
          fill(255,255,0);
          rect(px, py, TILE, TILE);
        }
      }
    }
  }
}

void drawPlayer() {
  imageMode(CENTER);
  if (imgPlayerSmall != null) {
    image(imgPlayerSmall, PlayerX, PlayerY);
  } else if (imgPlayer != null) {
    image(imgPlayer, PlayerX, PlayerY);
  } else {
    fill(255,255,0);
    ellipse(PlayerX, PlayerY, TILE*0.5, TILE*0.5);
  }
  imageMode(CORNER);
}


// ---------------------------------------------------
//                    SETUP & DRAW
// ---------------------------------------------------

void setup() {
  size(750, 650);
  smooth(4);

  // 玩家初始位置
  PlayerX = 275;
  PlayerY = 175;

  // 序列埠初始化
  println(Serial.list());           // 看有哪些 port
  myPort = new Serial(this, "COM5", 9600);  // 把 "COM5" 換成你的實際 COM
  myPort.clear();

  // 載入貼圖
  imgFloor     = loadImage("地板.png");
  imgWall      = loadImage("石頭.png");
  imgSoftWall  = loadImage("木箱.png");
  imgPlayer    = loadImage("玩家.png");
  imgEnemy     = loadImage("怪物.png");
  imgBomb      = loadImage("水球.png");
  imgFire      = loadImage("炸彈軌跡.png");
  imgItemBomb  = loadImage("增加炸彈.png");
  imgItemSpeed = loadImage("快鞋.png");
  imgItemPower = loadImage("增加威力.png");

  // 一次性縮放
  if (imgFloor  != null) imgFloor.resize(TILE, TILE);
  if (imgWall   != null) imgWall.resize(TILE, TILE);
  if (imgSoftWall != null) imgSoftWall.resize(TILE, TILE);
  if (imgBomb   != null) imgBomb.resize(TILE, TILE);
  if (imgFire   != null) imgFire.resize(TILE, TILE);

  if (imgPlayer != null) {
    imgPlayer.resize(TILE, TILE);
    imgPlayerSmall = imgPlayer.copy();
    imgPlayerSmall.resize(int(TILE*0.8), int(TILE*0.8));
  }
  if (imgEnemy != null) {
    imgEnemy.resize(TILE, TILE);
    imgEnemySmall = imgEnemy.copy();
    imgEnemySmall.resize(int(TILE*0.8), int(TILE*0.8));
  }
  if (imgItemBomb != null) {
    imgItemBomb.resize(TILE, TILE);
    imgItemBombSmall = imgItemBomb.copy();
    imgItemBombSmall.resize(int(TILE*0.7), int(TILE*0.7));
  }
  if (imgItemSpeed != null) {
    imgItemSpeed.resize(TILE, TILE);
    imgItemSpeedSmall = imgItemSpeed.copy();
    imgItemSpeedSmall.resize(int(TILE*0.7), int(TILE*0.7));
  }
  if (imgItemPower != null) {
    imgItemPower.resize(TILE, TILE);
    imgItemPowerSmall = imgItemPower.copy();
    imgItemPowerSmall.resize(int(TILE*0.7), int(TILE*0.7));
  }

  // 敵人初始位置
  enemies.add(new Enemy(0, 3));
  enemies.add(new Enemy(0, 10));
  enemies.add(new Enemy(14, 3));
  enemies.add(new Enemy(14, 10));
  enemies.add(new Enemy(2, 6));
  enemies.add(new Enemy(3, 6));
  enemies.add(new Enemy(4, 6));
  enemies.add(new Enemy(5, 6));
  enemies.add(new Enemy(6, 6));
  enemies.add(new Enemy(7, 6));
  enemies.add(new Enemy(8, 6));
}

void draw() {
  background(0);

  // ★ 讀 joystick 資料：每次讀三個 byte：X, Y, Button
  if (myPort != null && myPort.available() >= 3) {
    joyX   = myPort.read() & 0xFF;  // 0~255
    joyY   = myPort.read() & 0xFF;  // 0~255
    joyBtn = myPort.read() & 0xFF;  // 0 或 1
  }

  // ★ 用 joystick 決定 dx, dy
  int deadZone = 20;    // 中央死區
  dx = 0;
  dy = 0;
  if (joyX < 128 - deadZone) dx = -1;
  else if (joyX > 128 + deadZone) dx = 1;

  if (joyY < 128 - deadZone) dy = -1;
  else if (joyY > 128 + deadZone) dy = 1;

  // ★ 按鈕「從 0 → 1」那一瞬間放炸彈
  if (gameState == STATE_PLAYING) {
    if (joyBtn == 1 && joyBtnPrev == 0) {
      placebomb();
    }
  }

  if (gameState == STATE_PLAYING) {
    checkplayerleave();
    updateBombs();
    updateFires();

    // 更新敵人邏輯
    for (Enemy e : enemies) e.update();

    // 玩家滑順移動（pixel-based）
    float nextX = PlayerX + dx * playerSpeed;
    float nextY = PlayerY + dy * playerSpeed;

    int nextGX = int(nextX / TILE);
    int nextGY = int(nextY / TILE);

    boolean canmove = false;

    if (nextGX >= 0 && nextGX < COLS &&
        nextGY >= 0 && nextGY < ROWS &&
        walls[nextGX][nextGY] == 0)
      canmove = true;

    for (Bomb b : bombs)
      if (b.gx == nextGX && b.gy == nextGY && !b.playerLeft)
        canmove = true;

    if (canmove) {
      PlayerX = int(nextX);
      PlayerY = int(nextY);
    }

    pickupItems();
    checkEnemyHitPlayer();
    checkWin();
  }

  // 這一幀處理完，再更新 joyBtnPrev
  joyBtnPrev = joyBtn;

  // 畫場景
  drawMap();
  showfires();
  showItems();

  // 敵人 & 玩家
  for (Enemy e : enemies) e.show();
  drawPlayer();
  drawHUD();
}

// 現在鍵盤不用炸彈了，如果你想保留備用，可以打開下面那行
void keyPressed(){
  // if (key == ' ') placebomb();
}

void keyReleased(){
  // 不用處理 dx, dy 了，交給搖桿
}
