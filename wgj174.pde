float m2px = 5000;

float G = -1*-981*2;

float c_a_g = 0.7;
float c_f_g = 2;

float b_r = (0.06668-0.06350)/2*m2px;
float b_wgt = (58.5-56.7)/2;

PVector b_pos = new PVector(000, 100);
PVector b_v = new PVector(1000, -600);
PVector b_acc = new PVector(0, 0);

float h_acc = 1000;
int min_y = 100;

int prevMillis = 0;
int[][] tiles = new int[][]{
  {14,6,3,13}, {14,9,7,8},  {12,10,11,13}, {14,6,3,13}, {14,6,3,13}, {14,6,3,13}, {14,6,3,13}, {14,6,3,13}, 
  {14,6,3,13}, {14,6,3,13}, {14,6,3,13},   {14,6,3,13}, {14,6,3,13}, {14,6,3,13}, {14,6,5,4},  {14,6,1,1}, 
  {14,6,1,1},  {14,6,1,1},  {14,6,1,1},    {14,6,1,1},  {14,6,1,1},  {14,6,1,1},  {2,2,2,2},   {2,2,2,2}
};
float[][] walls = new float[][]{{195, 100, 195, 400}, {2200, 0, 2200, 400}};

int traceSize = 12;
PVector[] trace = new PVector[traceSize];

PVector screen_pos = new PVector(0, 0);
boolean moveLeft = false;
boolean started = true;

float dt = 0;

//draw cst
float terrainLineW = 5;

void setup() {
  size(600, 400);
  noStroke();
  background(33);
  for(int i=0; i<traceSize; i++){
    trace[i]=new PVector(0,0);
  }
  trace[0].x = b_pos.x;
  trace[0].y = b_pos.y;
}

void keyPressed() {
  if(key == CODED){
    if(keyCode == LEFT) {
      b_acc.x = -h_acc;
    }
    else if (keyCode == RIGHT) {
      b_acc.x = h_acc;
    }
  }
}

void keyReleased() {
  if(key == CODED){
    if(keyCode == LEFT) {
      b_acc.x = 0;
    }
    else if (keyCode == RIGHT) {
      b_acc.x = 0;
    }
  }
  else {
    if(key == ENTER){
      started = true;
    }
  }
}

void draw(){
  int millis = millis();
  dt = (float)(millis - prevMillis)/1000;
  prevMillis = millis;
  if(started) {
    background(33);
    drawTiles();
    drawBall();
    applyPhysics();
    shiftTrace();
  }
}

void drawBall(float x, float y, float alpha){
  fill(220, 253, 80, alpha);
  ellipseMode(CENTER);
  ellipse(x, y, b_r*2, b_r*2);
}

void drawBall() {
  for(int i=traceSize-1; i>=0; i--) {
    drawBall(trace[i].x, trace[i].y, 255-(255*((float)(i+1)/traceSize)));
  }
}

void drawTiles(){
  int start = (int)screen_pos.x/100;
  for(int i=start; i<start+width/100+1; i++){
    for(int j=0; j<height/100; j++) {
      drawTile(tiles[i][j], (i-start)*100-(int)screen_pos.x%100, j*100); 
    }
  }
}

void applyPhysics(){
  
  if(screen_pos.x>100){
    moveLeft = true;
  }
  
  if(b_r+b_pos.y<=height-min_y) {
    b_v.y = b_v.y+G*dt;
    b_acc.y=0;
  }
  else {
    if(b_v.y > 0) {
      b_v.y = -b_v.y*c_a_g;
    }
    float dvx = -c_f_g*dt*b_v.x;
    if(Math.abs(b_v.x) < 100) {
      dvx *= 2;
    }
    b_v.x += dvx;
    if(Math.abs(b_v.y) < 10) {
      b_v.y = 0;
    }
  }
  
  if(b_pos.x < 0){
    b_pos.x = 0;
    b_v.x = -b_v.x*c_a_g;
  }
  if(Math.abs(b_v.x)<1) {
    b_v.x = 0;
  }
  
  b_v.x += b_acc.x * dt;
  b_v.y += b_acc.y * dt;
  
  b_pos.x += b_v.x * dt;
  b_pos.y += b_v.y * dt;
  
  //Horizantal screen move
  //Right
  if(b_pos.x > 500){
    screen_pos.x += b_pos.x-500;
    moveTrace(b_pos.x-500, 0);
    b_pos.x = 500;
  }
  //Left
  else if(moveLeft && b_pos.x < 100){
    screen_pos.x -= 100-b_pos.x;
    moveTrace(b_pos.x-100, 0);
    b_pos.x = 100;
  }
  
  //Wall colision
  for(int i=0; i<walls.length; i++) {
    float wall_x = walls[i][0];
    float wall_min_y = walls[i][1];
    float wall_max_y = walls[i][3];
    if(b_pos.x+screen_pos.x-b_r <= wall_x && trace[0].x+screen_pos.x >= wall_x && (b_pos.y < wall_max_y && b_pos.y > wall_min_y)){
      b_pos.x = wall_x-screen_pos.x+b_r;
      b_v.x = -b_v.x*c_a_g;
    }
    else if(b_pos.x+screen_pos.x+b_r >= wall_x && trace[0].x+screen_pos.x <= wall_x && (b_pos.y < wall_max_y && b_pos.y > wall_min_y)){
      b_pos.x = wall_x-screen_pos.x-b_r;
      b_v.x = -b_v.x*c_a_g;
    }
  }
  
  //Register position
  shiftTrace();
  trace[0].x = b_pos.x;
  trace[0].y = b_pos.y;
}

void drawTile(int id, int x, int y){
  switch(id){
    //Orange ground
    case 1:
      fill(#D75C15);
      rect(x, y, 100, 100);
      break;
    //Green dark wall
    case 2:
      fill(#004C2E);
      rect(x, y, 100, 100);
      break;
    case 3:
      fill(#D75C15);
      rect(x, y, 100, 100);
      fill(#E0E0E0);
      rect(x, y+50, 100, terrainLineW);
      rect(x, y+65, 100, terrainLineW);
      break;
    case 4:
      fill(#D75C15);
      rect(x, y, 100, 100);
      fill(#E0E0E0);
      rect(x, y+50, 100, terrainLineW);
      rect(x, y+35, 100, terrainLineW);
      rect(x, y, terrainLineW, 50);
      rect(x+100-terrainLineW, y, terrainLineW, 50);
      break;
    case 5:
      fill(#D75C15);
      rect(x, y, 100, 100);
      fill(#E0E0E0);
      rect(x, y+50, 100, terrainLineW);
      rect(x, y+65, 100, terrainLineW);
      rect(x, y+50, terrainLineW, 50);
      rect(x+100-terrainLineW, y+50, terrainLineW, 50);
      break;
    case 6:
      fill(#007C4E);
      rect(x, y, 100, 100);
      break;
    //Net foregroung top
    case 7:
      fill(#D75C15);
      rect(x, y, 100, 100);
      fill(#E0E0E0);
      rect(x, y+50, 100, terrainLineW);
      rect(x, y+65, 100, terrainLineW);
      fill(#D0D0D0);
      rect(x+40, y+20, 10, 80);
      //Net
      stroke(#E0E0E0);
      for(int i=30; i<40; i+=1){
        line(x+50, y+i, x+50+i/1.5, y+00);
      }
      stroke(#202020);
      for(int i=50; i<190; i+=20){
        line(x+50, y+i, x+50+i/1.5, y+00);
      }
      for(int i=0; i<50; i+=10){
        line(x+60+i, y-(i*1.5-25), x+60+i, y+100);
      }
      noStroke();
      break;
    //Net foregroung bottom
    case 8:
      fill(#D75C15);
      rect(x, y, 100, 100);
      fill(#E0E0E0);
      rect(x, y+50, 100, terrainLineW);
      rect(x, y+35, 100, terrainLineW);
      fill(#D0D0D0);
      rect(x+40, y, 10, 85);
      //Net
      stroke(#202020);
      for(int i=10; i<80; i+=20){
        line(x+50, y+i, x+50+i/1.5, y+00);
      }
      for(int i=0; i<50; i+=10){
        line(x+60+i, y, x+60+i, y-(i*1.5-55));
      }
      noStroke();
      break;
    //Net middle top
    case 9:
      fill(#007C4E);
      rect(x, y, 100, 100);
      //Net
      stroke(#E0E0E0);
      for(int i=130; i<140; i+=1){
        line(x+50, y+i, x+50+i/1.5, y+00);
      }
      stroke(#202020);
      for(int i=150; i<210; i+=20){
        line(x+50, y+i, x+50+i/1.5, y+00);
      }
      for(int i=80; i<100; i+=10){
        line(x+i, y-(i*1.5-215), x+i, y+100);
      }
      noStroke();
      break;
    //Net backgrounf top
    case 10:
      fill(#007C4E);
      rect(x, y, 100, 100);
      //Poteau
      fill(#D0D0D0);
      rect(x+45, y+0, 10, 100);
      //Net
      stroke(#E0E0E0);
      for(int i=55; i<65; i+=1){
        line(x, y+i, x+50, y+i-75);
      }
      stroke(#202020);
      for(int i=75; i<210; i+=20){
        line(x, y+i, x+50, y+i-75);
      }
      for(int i=0; i<60; i+=10){
        line(x+i, y-(i*1.5-65), x+i, y+100);
      }
      noStroke();
      break;
    //Net backgrounf bottom
    case 11:
      fill(#D75C15);
      rect(x, y, 100, 100);
      fill(#E0E0E0);
      rect(x, y+50, 100, terrainLineW);
      rect(x, y+65, 100, terrainLineW);
      //Poteau
      fill(#D0D0D0);
      rect(x+45, y, 10, 40);
      //Net
      stroke(#202020);
      for(int i=15; i<105; i+=20){
        line(x, y+i, x+50, y+i-75);
      }
      for(int i=0; i<60; i+=10){
        line(x+i, y+00, x+i, y+95-(i*1.5));
      }
      noStroke();
      break;
    //Net backgroung over-top
    case 12:
      fill(#A0A0A0);
      rect(x, y, 100, 60);
      fill(#F0F0F0);
      rect(x+20, y+20, 80, 80, 20);
      fill(#007C4E);
      rect(x, y+60, 100, 40);
      //Poteau
      fill(#D0D0D0);
      rect(x+45, y+70, 10, 30);
      //Net
      stroke(#E0E0E0);
      for(int i=125; i<135; i+=1){
        line(x+20, y+i, x+50, y+i-45);
      }
      noStroke();
      break;
    case 13:
      fill(#D75C15);
      rect(x, y, 100, 100);
      fill(#E0E0E0);
      rect(x, y+50, 100, terrainLineW);
      rect(x, y+35, 100, terrainLineW);
      break;
    case 14:
      fill(#A0A0A0);
      rect(x, y, 100, 60);
      fill(#F0F0F0);
      rect(x+20, y+20, 80, 80, 20);
      fill(#007C4E);
      rect(x, y+60, 100, 40);
      break;
  }
}

void moveTrace(float x, float y) {
  for(int i=0; i<traceSize; i++){
    trace[i].x -= x;
    trace[i].y -= y;
  }
}

void shiftTrace(){
  for(int i=(traceSize-1)-1; i>=0; i--){
    trace[i+1].x=trace[i].x;
    trace[i+1].y=trace[i].y;
  }
}
