// =====================================================
// 爆爆王：單人 + 怪物 + 道具 + 補間移動 + 追玩家AI + 全貼圖版
// 控制：方向鍵移動，Space 放炸彈，R 重新開始
// =====================================================

import java.util.*;

// 地圖大小
int COLS = 13;
int ROWS = 11;
int CELL = 48;

// 地圖格子類型
final int EMPTY = 0;
final int HARD  = 1;   // 不可破壞牆
final int SOFT  = 2;   // 可破壞牆

int[][] map;

// 玩家、炸彈、火焰、怪物、道具
Player player;
ArrayList<Bomb> bombs    = new ArrayList<Bomb>();
ArrayList<Fire> fires    = new ArrayList<Fire>();
ArrayList<Enemy> enemies = new ArrayList<Enemy>();
ArrayList<Item> items    = new ArrayList<Item>();  // 道具列表

// 道具種類
final int ITEM_BOMB   = 0; // 增加炸彈數量
final int ITEM_RANGE  = 1; // 增加炸彈範圍
final int ITEM_SPEED  = 2; // 增加移動速度

// 遊戲狀態
final int STATE_PLAYING   = 0;
final int STATE_GAME_OVER = 1;
final int STATE_WIN       = 2;
int gameState = STATE_PLAYING;

PFont font;

// 貼圖
PImage texHard;      // 石頭牆
PImage texSoft;      // 木箱牆
PImage texFloor;     // 地板
PImage texBomb;      // 水球炸彈
PImage texPlayer;    // 玩家
PImage texSpeed;     // 加速鞋
PImage texItemBomb;  // 增加炸彈數道具
PImage texEnemy;     // 怪物
PImage texFire;      // 炸彈軌跡 / 火焰

// -----------------------------------------------------
// 視窗設定
// -----------------------------------------------------
void settings() {
  size(COLS * CELL, ROWS * CELL);
}

// -----------------------------------------------------
// setup：初始化
// -----------------------------------------------------
void setup() {
  font = createFont("Consolas", 24);
  textFont(font);

  // 載入貼圖（放在 data/）
  texHard     = loadImage("石頭.png");
  texSoft     = loadImage("木箱.png");
  texFloor    = loadImage("地板.png");
  texBomb     = loadImage("水球.png");
  texPlayer   = loadImage("玩家.png");
  texSpeed    = loadImage("快鞋.png");
  texItemBomb = loadImage("增加炸彈.png");
  texEnemy    = loadImage("怪物.png");
  texFire     = loadImage("炸彈軌跡.png");

  // 縮到格子大小，避免太大
  if (texHard     != null) texHard.resize(CELL, CELL);
  if (texSoft     != null) texSoft.resize(CELL, CELL);
  if (texFloor    != null) texFloor.resize(CELL, CELL);
  if (texBomb     != null) texBomb.resize(CELL, CELL);
  if (texPlayer   != null) texPlayer.resize(CELL, CELL);
  if (texSpeed    != null) texSpeed.resize(CELL, CELL);
  if (texItemBomb != null) texItemBomb.resize(CELL, CELL);
  if (texEnemy    != null) texEnemy.resize(CELL, CELL);
  if (texFire     != null) texFire.resize(CELL, CELL);

  initMap();
  player = new Player(1, 1);  // 左上角起點
  initEnemies();
}

// -----------------------------------------------------
// draw：主迴圈
// -----------------------------------------------------
void draw() {
  background(0);
  
  if (gameState == STATE_PLAYING) {
    player.update();      // 玩家補間動畫更新
    updateBombs();
    updateFires();
    updateEnemies();      // 怪物補間動畫更新
    checkPlayerHit();     // 火焰 / 怪物 打到玩家
    checkEnemyHit();      // 火焰 打到怪物
    checkWinCondition();  // 判斷是否通關
  }
  
  drawMap();
  drawItems();
  drawBombs();
  drawFires();
  drawEnemies();
  drawPlayer();
  drawHUD();
}

// ---------------------- 地圖 & 怪物初始化 ----------------------

void initMap() {
  map = new int[COLS][ROWS];
  
  // 外圍硬牆
  for (int x = 0; x < COLS; x++) {
    map[x][0] = HARD;
    map[x][ROWS-1] = HARD;
  }
  for (int y = 0; y < ROWS; y++) {
    map[0][y] = HARD;
    map[COLS-1][y] = HARD;
  }
  
  // 棋盤狀硬牆
  for (int x = 2; x < COLS-1; x += 2) {
    for (int y = 2; y < ROWS-1; y += 2) {
      map[x][y] = HARD;
    }
  }
  
  // 隨機放一些軟牆
  for (int i = 0; i < 35; i++) {
    int rx = int(random(1, COLS-1));
    int ry = int(random(1, ROWS-1));
    if ((rx <= 2 && ry <= 2) || map[rx][ry] != EMPTY) continue;
    map[rx][ry] = SOFT;
  }
}

void initEnemies() {
  enemies.clear();
  int count = 0;
  while (count < 3) {
    int rx = int(random(1, COLS-1));
    int ry = int(random(1, ROWS-1));
    if (map[rx][ry] == EMPTY && !(rx <= 2 && ry <= 2)) {
      enemies.add(new Enemy(rx, ry));
      count++;
    }
  }
  items.clear();
}

// ---------------------- 類別定義 -----------------------

// 玩家
class Player {
  int gx, gy;
  boolean alive = true;
  int bombRange = 1;
  int maxBombs = 1;

  int moveInterval = 150;
  int lastMoveTime = 0;

  boolean moving = false;
  int moveStartTime = 0;
  int moveDuration = 150;
  int destGx, destGy;
  float renderX, renderY;
  float startX, startY;
  float destX, destY;
  
  Player(int x, int y) {
    gx = x;
    gy = y;
    renderX = gx * CELL;
    renderY = gy * CELL;
    moveStartTime = millis();
    lastMoveTime = millis();
    moveDuration = moveInterval;
  }
  
  void update() {
    if (!moving) return;
    float t = (millis() - moveStartTime) / (float)moveDuration;
    if (t >= 1.0) {
      moving = false;
      gx = destGx;
      gy = destGy;
      renderX = destX;
      renderY = destY;
      pickupItem();
    } else {
      t = constrain(t, 0, 1);
      renderX = lerp(startX, destX, t);
      renderY = lerp(startY, destY, t);
    }
  }
  
  void tryMove(int dx, int dy) {
    if (!alive || gameState != STATE_PLAYING) return;
    if (moving) return;
    if (millis() - lastMoveTime < moveInterval) return;
    lastMoveTime = millis();

    int nx = gx + dx;
    int ny = gy + dy;
    if (nx < 0 || nx >= COLS || ny < 0 || ny >= ROWS) return;
    if (map[nx][ny] == HARD || map[nx][ny] == SOFT) return;
    
    for (Bomb b : bombs) {
      if (!b.exploded && b.gx == nx && b.gy == ny) return;
    }
    
    moving = true;
    moveStartTime = millis();
    moveDuration = moveInterval;
    destGx = nx;
    destGy = ny;
    startX = renderX;
    startY = renderY;
    destX  = destGx * CELL;
    destY  = destGy * CELL;
  }
  
  void placeBomb() {
    if (!alive || gameState != STATE_PLAYING) return;
    int active = 0;
    for (Bomb b : bombs) if (!b.exploded) active++;
    if (active >= maxBombs) return;
    for (Bomb b : bombs) if (!b.exploded && b.gx == gx && b.gy == gy) return;
    bombs.add(new Bomb(gx, gy, bombRange));
  }
  
  void pickupItem() {
    Iterator<Item> it = items.iterator();
    while (it.hasNext()) {
      Item itx = it.next();
      if (itx.gx == gx && itx.gy == gy) {
        if (itx.type == ITEM_BOMB) {
          maxBombs = min(maxBombs + 1, 5);
        } else if (itx.type == ITEM_RANGE) {
          bombRange = min(bombRange + 1, 5);
        } else if (itx.type == ITEM_SPEED) {
          moveInterval = max(moveInterval - 50, 50);
        }
        it.remove();
      }
    }
  }
}

// 炸彈
class Bomb {
  int gx, gy;
  int range;
  int placedTime;
  int fuse = 2000;
  boolean exploded = false;
  
  Bomb(int x, int y, int r) {
    gx = x;
    gy = y;
    range = r;
    placedTime = millis();
  }
}

// 火焰
class Fire {
  int gx, gy;
  int created;
  int duration = 400;
  
  Fire(int x, int y) {
    gx = x;
    gy = y;
    created = millis();
  }
}

// 怪物
class Enemy {
  int gx, gy;
  boolean alive = true;
  int moveInterval = 500;
  int lastMoveTime = 0;

  boolean moving = false;
  int moveStartTime = 0;
  int moveDuration = 300;
  int destGx, destGy;
  float renderX, renderY;
  float startX, startY;
  float destX, destY;
  
  Enemy(int x, int y) {
    gx = x;
    gy = y;
    renderX = gx * CELL;
    renderY = gy * CELL;
    lastMoveTime = millis();
    moveStartTime = millis();
  }
  
  void update() {
    if (!alive) return;
    
    if (moving) {
      float t = (millis() - moveStartTime) / (float)moveDuration;
      if (t >= 1.0) {
        moving = false;
        gx = destGx;
        gy = destGy;
        renderX = destX;
        renderY = destY;
      } else {
        t = constrain(t, 0, 1);
        renderX = lerp(startX, destX, t);
        renderY = lerp(startY, destY, t);
      }
      return;
    }
    
    if (millis() - lastMoveTime < moveInterval) return;
    lastMoveTime = millis();
    
    int[][] dirs = { {1,0}, {-1,0}, {0,1}, {0,-1} };
    int[] order = {0,1,2,3};
    for (int i = 0; i < 4; i++) {
      int j = int(random(i, 4));
      int tmp = order[i]; order[i] = order[j]; order[j] = tmp;
    }
    
    // 有機率偏向玩家方向
    if (random(1) < 0.6) {
      int towardIdx = -1;
      int dxToPlayer = player.gx - gx;
      int dyToPlayer = player.gy - gy;
      if (abs(dxToPlayer) > abs(dyToPlayer)) {
        if (dxToPlayer > 0) towardIdx = 0;
        else if (dxToPlayer < 0) towardIdx = 1;
      } else if (abs(dyToPlayer) > 0) {
        if (dyToPlayer > 0) towardIdx = 2;
        else if (dyToPlayer < 0) towardIdx = 3;
      }
      if (towardIdx != -1) {
        for (int i = 0; i < 4; i++) {
          if (order[i] == towardIdx) {
            int tmp = order[0]; order[0] = order[i]; order[i] = tmp;
            break;
          }
        }
      }
    }
    
    for (int k = 0; k < 4; k++) {
      int d = order[k];
      int nx = gx + dirs[d][0];
      int ny = gy + dirs[d][1];
      if (nx < 0 || nx >= COLS || ny < 0 || ny >= ROWS) continue;
      if (map[nx][ny] == HARD || map[nx][ny] == SOFT) continue;
      
      boolean blocked = false;
      for (Bomb b : bombs)
        if (!b.exploded && b.gx == nx && b.gy == ny) { blocked = true; break; }
      if (blocked) continue;
      for (Enemy e : enemies)
        if (e != this && e.alive && e.gx == nx && e.gy == ny) { blocked = true; break; }
      if (blocked) continue;
      
      moving = true;
      moveStartTime = millis();
      destGx = nx;
      destGy = ny;
      startX = renderX;
      startY = renderY;
      destX = destGx * CELL;
      destY = destGy * CELL;
      break;
    }
  }
}

// 道具
class Item {
  int gx, gy;
  int type;
  Item(int x, int y, int t) { gx = x; gy = y; type = t; }
}

// ---------------------- 遊戲邏輯 -----------------------

void updateBombs() {
  int now = millis();
  ArrayList<Bomb> toRemove = new ArrayList<Bomb>();
  for (Bomb b : bombs) {
    if (!b.exploded && now - b.placedTime >= b.fuse) {
      explodeBomb(b);
      b.exploded = true;
      toRemove.add(b);
    }
  }
  bombs.removeAll(toRemove);
}

void explodeBomb(Bomb b) {
  fires.add(new Fire(b.gx, b.gy));
  destroySoftBlock(b.gx, b.gy);
  
  int[][] dirs = { {1,0}, {-1,0}, {0,1}, {0,-1} };
  for (int i = 0; i < 4; i++) {
    int dx = dirs[i][0];
    int dy = dirs[i][1];
    int cx = b.gx;
    int cy = b.gy;
    for (int step = 1; step <= b.range; step++) {
      cx += dx;
      cy += dy;
      if (cx < 0 || cx >= COLS || cy < 0 || cy >= ROWS) break;
      if (map[cx][cy] == HARD) break;
      if (map[cx][cy] == SOFT) {
        destroySoftBlock(cx, cy);
        break;
      }
      fires.add(new Fire(cx, cy));
    }
  }
}

void destroySoftBlock(int x, int y) {
  if (map[x][y] == SOFT) {
    map[x][y] = EMPTY;
    maybeSpawnItem(x, y);
  }
}

void maybeSpawnItem(int x, int y) {
  float p = random(1);
  if (p < 0.4) {
    int t = int(random(3)); // 0,1,2
    items.add(new Item(x, y, t));
  }
}

void updateFires() {
  int now = millis();
  ArrayList<Fire> toRemove = new ArrayList<Fire>();
  for (Fire f : fires) {
    if (now - f.created > f.duration) toRemove.add(f);
  }
  fires.removeAll(toRemove);
}

void updateEnemies() {
  for (Enemy e : enemies) e.update();
}

void checkPlayerHit() {
  if (!player.alive || gameState != STATE_PLAYING) return;
  for (Fire f : fires)
    if (f.gx == player.gx && f.gy == player.gy) {
      player.alive = false;
      gameState = STATE_GAME_OVER;
      return;
    }
  for (Enemy e : enemies)
    if (e.alive && e.gx == player.gx && e.gy == player.gy) {
      player.alive = false;
      gameState = STATE_GAME_OVER;
      return;
    }
}

void checkEnemyHit() {
  for (Enemy e : enemies) {
    if (!e.alive) continue;
    for (Fire f : fires)
      if (f.gx == e.gx && f.gy == e.gy) {
        e.alive = false;
        break;
      }
  }
}

void checkWinCondition() {
  boolean hasSoft = false;
  for (int x = 0; x < COLS; x++) {
    for (int y = 0; y < ROWS; y++) {
      if (map[x][y] == SOFT) { hasSoft = true; break; }
    }
    if (hasSoft) break;
  }
  boolean anyEnemyAlive = false;
  for (Enemy e : enemies) if (e.alive) { anyEnemyAlive = true; break; }
  if (!hasSoft && !anyEnemyAlive && gameState == STATE_PLAYING)
    gameState = STATE_WIN;
}

// ---------------------- 繪製 ---------------------------

void drawMap() {
  stroke(60);
  for (int x = 0; x < COLS; x++) {
    for (int y = 0; y < ROWS; y++) {
      int cx = x * CELL;
      int cy = y * CELL;
      int type = map[x][y];

      if (type == HARD) {
        if (texHard != null) image(texHard, cx, cy);
        else { fill(80,80,100); rect(cx, cy, CELL, CELL); }

      } else if (type == SOFT) {
        if (texSoft != null) image(texSoft, cx, cy);
        else { fill(150,110,70); rect(cx, cy, CELL, CELL); }

      } else { // EMPTY 地板
        if (texFloor != null) image(texFloor, cx, cy);
        else { fill(40); rect(cx, cy, CELL, CELL); }
      }
    }
  }
}

void drawItems() {
  noStroke();
  for (Item it : items) {
    int cx = it.gx * CELL;
    int cy = it.gy * CELL;
    if (it.type == ITEM_BOMB) {
      if (texItemBomb != null) {
        image(texItemBomb, cx, cy);
      } else {
        fill(0, 180, 255);
        ellipse(cx + CELL/2, cy + CELL/2, CELL*0.5, CELL*0.5);
      }
    } else if (it.type == ITEM_RANGE) {
      fill(255, 80, 80);
      rect(cx + CELL*0.2, cy + CELL*0.2, CELL*0.6, CELL*0.6, 4);
    } else if (it.type == ITEM_SPEED) {
      if (texSpeed != null) {
        image(texSpeed, cx, cy);
      } else {
        fill(80, 255, 80);
        triangle(cx + CELL*0.2, cy + CELL*0.7,
                 cx + CELL*0.5, cy + CELL*0.3,
                 cx + CELL*0.8, cy + CELL*0.7);
      }
    }
  }
}

void drawPlayer() {
  if (!player.alive) return;
  int px = int(player.renderX);
  int py = int(player.renderY);
  if (texPlayer != null) {
    image(texPlayer, px, py);
  } else {
    fill(0, 200, 255);
    rect(px+8, py+8, CELL-16, CELL-16, 10);
  }
}

void drawEnemies() {
  noStroke();
  for (Enemy e : enemies) {
    if (!e.alive) continue;
    int ex = int(e.renderX);
    int ey = int(e.renderY);
    if (texEnemy != null) {
      image(texEnemy, ex, ey);
    } else {
      fill(200, 0, 200);
      rect(ex+10, ey+10, CELL-20, CELL-20, 6);
    }
  }
}

void drawBombs() {
  noStroke();
  for (Bomb b : bombs) {
    if (!b.exploded) {
      float cx = b.gx * CELL + CELL * 0.5;
      float cy = b.gy * CELL + CELL * 0.5;
      if (texBomb != null) {
        imageMode(CENTER);
        image(texBomb, cx, cy);
        imageMode(CORNER);
      } else {
        fill(255, 220, 0);
        ellipse(cx, cy, CELL*0.6, CELL*0.6);
      }
    }
  }
}

void drawFires() {
  noStroke();
  for (Fire f : fires) {
    int cx = f.gx * CELL;
    int cy = f.gy * CELL;
    if (texFire != null) {
      image(texFire, cx, cy);
    } else {
      float t = (millis() - f.created) / float(f.duration);
      t = constrain(t, 0, 1);
      int r = int(lerp(255, 255, t));
      int g = int(lerp(230, 60, t));
      int b = int(lerp(0, 0, t));
      fill(r, g, b, 220);
      rect(cx+6, cy+6, CELL-12, CELL-12, 6);
    }
  }
}

void drawHUD() {
  fill(255);
  textAlign(LEFT, TOP);
  text("Arrow Keys: Move   Space: Bomb   R: Restart", 8, 8);
  text("Bombs: " + player.maxBombs + "  Range: " + player.bombRange +
       "  Interval: " + player.moveInterval + "ms", 8, 32);
  if (gameState == STATE_GAME_OVER) {
    fill(255, 80, 80);
    textAlign(CENTER, CENTER);
    text("GAME OVER\nPress R to restart", width/2, height/2);
  } else if (gameState == STATE_WIN) {
    fill(80, 255, 80);
    textAlign(CENTER, CENTER);
    text("YOU WIN!\nPress R to restart", width/2, height/2);
  }
}

// ---------------------- 鍵盤操作 -----------------------

void keyPressed() {
  if (key == 'r' || key == 'R') {
    restartGame();
    return;
  }
  if (gameState != STATE_PLAYING) return;
  if (keyCode == UP)    player.tryMove(0, -1);
  if (keyCode == DOWN)  player.tryMove(0,  1);
  if (keyCode == LEFT)  player.tryMove(-1, 0);
  if (keyCode == RIGHT) player.tryMove(1,  0);
  if (key == ' ' )      player.placeBomb();
}

void restartGame() {
  initMap();
  player = new Player(1, 1);
  bombs.clear();
  fires.clear();
  items.clear();
  initEnemies();
  gameState = STATE_PLAYING;
}
