color [] c = {#CEC2B9,#EFE5DA,#EDE1CA,#EFB37E,#EF7F63,#EF7F63};
color [] c2 = {#776E66,#776E66,#776E66,#FDF8F5,#FDF8F5,#FDF8F5};
int [] N = {0,2,4,8,16,32};
int [][] B = {{0,0,0,0},{1,2,3,4},{5,0,0,0},{0,0,0,0}};
void keyPressed(){
  genTwo();
}
void genTwo(){
  int zero = 0 ;
  for(int i=0;i<4;i++)for(int j=0;j<4;j++)if(B[i][j]==0)zero++;
  int ans=int(random(zero));
  for(int i=0;i<4;i++){
    for(int j=0;j<4;j++){
      if(B[i][j]==0){
        if(ans==0){
          B[i][j]=1;
          return ;
        }else ans--;
      }
    }
  }
}
void setup(){
  size(410, 410);
}

void draw(){
  background(188,174,162);
  for(int i=0;i<4;i++){
    for(int j=0;j<4;j++){
      int id = B[i][j];
      fill(c[id]);
      noStroke();
      rect(j*100+10,i*100+10,90,90,5);
      fill(c2[id]);
      textAlign(CENTER,CENTER);
      textSize(60);
      text(N[id],j*100+55,i*100+55);
    }
  }
}
