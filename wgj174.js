let m2px = 5000;

let G = -1*-981*2;

let c_a_g = 0.7;
let c_f_g = 2;

let b_r = (0.06668-0.06350)/2*m2px;
let b_wgt = (58.5-56.7)/2;

let b_pos;
let b_v;
let b_acc;

let h_acc = 1000;
let min_y = 100;

let prevMillis = 0;
let tiles = [
  [14,6,3,13], [14,9,7,8],  [12,10,11,13], [14,6,3,13], [14,6,3,13], [14,6,3,13], [14,6,3,13], [14,6,3,13], 
  [14,6,3,13], [14,6,3,13], [14,6,3,13],   [14,6,3,13], [14,6,3,13], [14,6,3,13], [14,6,5,4],  [14,6,1,1], 
  [14,6,1,1],  [14,6,1,1],  [14,6,1,1],    [14,6,1,1],  [14,6,1,1],  [14,6,1,1],  [2,2,2,2],   [2,2,2,2]
];
let walls = [[195, 100, 195, 400], [2200, 0, 2200, 400]];

let traceSize = 12;
let trace = new Array(traceSize);

let screen_pos;
let moveLeft = false;
let started = true;

let dt = 0;

//draw cst
let terrainLineW = 5;

function setup() {
  createCanvas(600, 400);
  noStroke();
  background(33);
  for(let i=0; i<traceSize; i++){
    trace[i]=createVector(0,0);
  }
  b_pos = createVector(0, 100);
  b_v = createVector(1000, -600);
  b_acc = createVector(0, 0);
  screen_pos = createVector(0, 0);
  trace[0].x = b_pos.x;
  trace[0].y = b_pos.y;
}

function keyPressed() {
    if(keyCode == LEFT_ARROW) {
      b_acc.x = -h_acc;
    }
    else if (keyCode == RIGHT_ARROW) {
      b_acc.x = h_acc;
    }
}

function keyReleased() {
    if(keyCode == LEFT_ARROW) {
      b_acc.x = 0;
    }
    else if (keyCode == RIGHT_ARROW) {
      b_acc.x = 0;
    }
    if(key == ENTER){
      started = true;
    }
}

function draw(){
  let mil = millis();
  dt = (mil - prevMillis)/1000;
  prevMillis = mil;
  if(started) {
    background(33);
    drawTiles();
    drawBallTrace();
    applyPhysics();
    shiftTrace();
  }
}

function drawBall(x, y, alpha){
  fill(220, 253, 80, alpha);
  ellipseMode(CENTER);
  ellipse(x, y, b_r*2, b_r*2);
}

function drawBallTrace() {
  for(i=traceSize-1; i>=0; i--) {
    drawBall(trace[i].x, trace[i].y, 255-(255*((i+1)/traceSize)));
  }
}

function drawTiles(){
  let start = Math.floor(screen_pos.x/100);
  for(i=start; i<start+width/100+1; i++){
    for(j=0; j<height/100; j++) {
      drawTile(tiles[i][j], (i-start)*100-screen_pos.x%100, j*100); 
    }
  }
}

function applyPhysics(){
  
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
    let dvx = -c_f_g*dt*b_v.x;
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
  for(let i=0; i<walls.length; i++) {
    let wall_x = walls[i][0];
    let wall_min_y = walls[i][1];
    let wall_max_y = walls[i][3];
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

function drawTile(id, x, y){
  switch(id){
    //Orange ground
    case 1:
      fill("#D75C15");
      rect(x, y, 100, 100);
      break;
    //Green dark wall
    case 2:
      fill("#004C2E");
      rect(x, y, 100, 100);
      break;
    case 3:
      fill("#D75C15");
      rect(x, y, 100, 100);
      fill("#E0E0E0");
      rect(x, y+50, 100, terrainLineW);
      rect(x, y+65, 100, terrainLineW);
      break;
    case 4:
      fill("#D75C15");
      rect(x, y, 100, 100);
      fill("#E0E0E0");
      rect(x, y+50, 100, terrainLineW);
      rect(x, y+35, 100, terrainLineW);
      rect(x, y, terrainLineW, 50);
      rect(x+100-terrainLineW, y, terrainLineW, 50);
      break;
    case 5:
      fill("#D75C15");
      rect(x, y, 100, 100);
      fill("#E0E0E0");
      rect(x, y+50, 100, terrainLineW);
      rect(x, y+65, 100, terrainLineW);
      rect(x, y+50, terrainLineW, 50);
      rect(x+100-terrainLineW, y+50, terrainLineW, 50);
      break;
    case 6:
      fill("#007C4E");
      rect(x, y, 100, 100);
      break;
    //Net foregroung top
    case 7:
      fill("#D75C15");
      rect(x, y, 100, 100);
      fill("#E0E0E0");
      rect(x, y+50, 100, terrainLineW);
      rect(x, y+65, 100, terrainLineW);
      fill("#D0D0D0");
      rect(x+40, y+20, 10, 80);
      //Net
      stroke("#E0E0E0");
      for(let i=30; i<40; i+=1){
        line(x+50, y+i, x+50+i/1.5, y+00);
      }
      stroke("#202020");
      for(let i=50; i<190; i+=20){
        line(x+50, y+i, x+50+i/1.5, y+00);
      }
      for(let i=0; i<50; i+=10){
        line(x+60+i, y-(i*1.5-25), x+60+i, y+100);
      }
      noStroke();
      break;
    //Net foregroung bottom
    case 8:
      fill("#D75C15");
      rect(x, y, 100, 100);
      fill("#E0E0E0");
      rect(x, y+50, 100, terrainLineW);
      rect(x, y+35, 100, terrainLineW);
      fill("#D0D0D0");
      rect(x+40, y, 10, 85);
      //Net
      stroke("#202020");
      for(let i=10; i<80; i+=20){
        line(x+50, y+i, x+50+i/1.5, y+00);
      }
      for(let i=0; i<50; i+=10){
        line(x+60+i, y, x+60+i, y-(i*1.5-55));
      }
      noStroke();
      break;
    //Net middle top
    case 9:
      fill("#007C4E");
      rect(x, y, 100, 100);
      //Net
      stroke("#E0E0E0");
      for(let i=130; i<140; i+=1){
        line(x+50, y+i, x+50+i/1.5, y+00);
      }
      stroke("#202020");
      for(let i=150; i<210; i+=20){
        line(x+50, y+i, x+50+i/1.5, y+00);
      }
      for(let i=80; i<100; i+=10){
        line(x+i, y-(i*1.5-215), x+i, y+100);
      }
      noStroke();
      break;
    //Net backgrounf top
    case 10:
      fill("#007C4E");
      rect(x, y, 100, 100);
      //Poteau
      fill("#D0D0D0");
      rect(x+45, y+0, 10, 100);
      //Net
      stroke("#E0E0E0");
      for(let i=55; i<65; i+=1){
        line(x, y+i, x+50, y+i-75);
      }
      stroke("#202020");
      for(let i=75; i<210; i+=20){
        line(x, y+i, x+50, y+i-75);
      }
      for(let i=0; i<60; i+=10){
        line(x+i, y-(i*1.5-65), x+i, y+100);
      }
      noStroke();
      break;
    //Net backgrounf bottom
    case 11:
      fill("#D75C15");
      rect(x, y, 100, 100);
      fill("#E0E0E0");
      rect(x, y+50, 100, terrainLineW);
      rect(x, y+65, 100, terrainLineW);
      //Poteau
      fill("#D0D0D0");
      rect(x+45, y, 10, 40);
      //Net
      stroke("#202020");
      for(let i=15; i<105; i+=20){
        line(x, y+i, x+50, y+i-75);
      }
      for(let i=0; i<60; i+=10){
        line(x+i, y+00, x+i, y+95-(i*1.5));
      }
      noStroke();
      break;
    //Net backgroung over-top
    case 12:
      fill("#A0A0A0");
      rect(x, y, 100, 60);
      fill("#F0F0F0");
      rect(x+20, y+20, 80, 80, 20);
      fill("#007C4E");
      rect(x, y+60, 100, 40);
      //Poteau
      fill("#D0D0D0");
      rect(x+45, y+70, 10, 30);
      //Net
      stroke("#E0E0E0");
      for(let i=125; i<135; i+=1){
        line(x+20, y+i, x+50, y+i-45);
      }
      noStroke();
      break;
    case 13:
      fill("#D75C15");
      rect(x, y, 100, 100);
      fill("#E0E0E0");
      rect(x, y+50, 100, terrainLineW);
      rect(x, y+35, 100, terrainLineW);
      break;
    case 14:
      fill("#A0A0A0");
      rect(x, y, 100, 60);
      fill("#F0F0F0");
      rect(x+20, y+20, 80, 80, 20);
      fill("#007C4E");
      rect(x, y+60, 100, 40);
      break;
  }
}

function moveTrace(x, y) {
  for(let i=0; i<traceSize; i++){
    trace[i].x -= x;
    trace[i].y -= y;
  }
}

function shiftTrace(){
  for(let i=(traceSize-1)-1; i>=0; i--){
    trace[i+1].x=trace[i].x;
    trace[i+1].y=trace[i].y;
  }
}
