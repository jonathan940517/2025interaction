// week11_3_pacman_part2_move_x_y_void_keyPressed
void setup(){
  size(500, 500);
}
int x = 250, y= 250, dx=0, dy=0; 
float m=0, dm=0.05;  
void draw(){
  background(0);
  fill(255, 255, 0); 
  arc(x, y, 30, 30, +m, PI*2-m);
  x += dx; 
  y += dy; 
  if( m>=1 || m<0 ) dm = -dm; 
  m += dm;
}
void keyPressed(){
  if(keyCode==LEFT) { dx=-1; dy=0;}
  if(keyCode==RIGHT) { dx=+1; dy=0; }
  if(keyCode==UP) { dx=0; dy=-1; }
  if(keyCode==DOWN) { dx=0; dy=+1; }
}
