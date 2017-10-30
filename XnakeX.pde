//Xtion*****

import SimpleOpenNI.*;
//import maxlink.*;
PFont font;
SimpleOpenNI  context;
color[]       userClr = new color[]{ color(255,0,0),
                                     color(0,255,0),
                                     color(0,0,255),
                                     color(255,255,0),
                                     color(255,0,255),
                                     color(0,255,255)
                                   };
PVector com = new PVector();                                   
PVector com2d = new PVector();          
//MaxLink link = new MaxLink(this, "transfer"); // ** added for MaxLink

int liftcountold=0;
int liftcountnew=0;
int liftN=0;
int leancountold=2;
int leancountnew=2;
int turnright=0;
int turnleft=0;

//snake*****00

import processing.video.*;
import ddf.minim.*;

Movie evolution;

Minim minim;

PImage head;
PImage body;
PImage mushroom;
PImage lwing;
PImage rwing;
PImage feather;

AudioPlayer snake;
AudioPlayer ding;
AudioPlayer finish;
AudioPlayer wing;

int fruitN=1;
int eggN=1;
int wingN=0;

int [] eggMap = new int[120*120];
 
int headX=50,headY=50;
int dir=0;
int [] dirX={2,0,-2,0};
int [] dirY={0,2,0,-2};

void setup(){
  
  //Xtion*****setup
  
  context = new SimpleOpenNI(this);
  if(context.isInit() == false)
  {
     println("Can't init SimpleOpenNI, maybe the camera is not connected!"); 
     exit();
     return;  
  }
  context.setMirror(true);
  // enable depthMap generation 
  context.enableDepth();
  // enable skeleton generation for all joints
  context.enableUser();
  context.enableRGB();

  /*stroke(0,0,255);
  strokeWeight(3);
  smooth(); 
  font = createFont ("Geneva",30);
  textFont (font);*/
  
  //snake*****setup
  
  size(1000,1000);
  frameRate(5);
  
  for(int i=0;i<100*100;i++){
    eggMap[i]=0;
  }
 
  createNextFruit();
  
  head = loadImage("head.png");
  head.resize(40,40);
  body = loadImage("body.png");
  body.resize(40,40);
  mushroom = loadImage("mushroom.png");
  mushroom.resize(45,45);
  lwing = loadImage("allwhitewingsL.png");
  lwing.resize(500,200);
  rwing = loadImage("allwhitewingsR.png");
  rwing.resize(500,200);
  feather = loadImage("feather.png");
  feather.resize(500,500);
  //imageMode(CENTER);

  minim = new Minim(this);
  snake = minim.loadFile("snake.mp3");
  ding = minim.loadFile("ding.mp3");
  finish = minim.loadFile("finish.mp3");
  wing = minim.loadFile("wing.mp3");
  
  evolution = new Movie(this, "evolution.mp4");
}


void draw(){

  //Xtion*****draw
  
  context.update();// update the cam
  // draw depthImageMap
  //image(context.depthImage(),0,0);
  //image(context.userImage(),0,0,1000,1000);
  //image(context.rgbImage(), 0, 0,1000,1000);
  
  //snake*****draw
  
  if(wingN==1){
    image(context.rgbImage(), 0, 0,1000,1000);
    //image(context.userImage(),0,0,1000,1000);
    setXtion();
    wing.play();
  }else if(eggN==3){
    setXtion();
    snake.pause();
    image(evolution, 0, 0, 1000, 1000);
    evolution.play();
    println(liftcountnew);
    println(liftN);
    
    if(liftN<10&&evolution.time()>8.7){
      evolution.jump(5.1);
      println(liftcountnew);
      println(liftN);
    }else if(liftN>9&&liftN<20&&evolution.time()>12.7){
      evolution.jump(9.2);
    }else if(liftN>19&&evolution.time()>15){
      finish.play();
      liftN=0;
      wingN=1;
      eggN=5;
    }
  }else if(eggN<4){
    setXtion();
    background(255);
    update();
  }
}

void setXtion(){
  int[] userList = context.getUsers();
  for(int i=0;i<userList.length;i++)
  {
    if(context.isTrackingSkeleton(userList[i]))
    {
      stroke(userClr[ (userList[i] - 1) % userClr.length ] );
      drawSkeleton(userList[i]);
    }    
      
    if(context.getCoM(userList[i],com))
    {
      context.convertRealWorldToProjective(com,com2d);
      stroke(100,255,0);
      strokeWeight(1);
      beginShape(LINES);
        vertex(com2d.x,com2d.y - 5);
        vertex(com2d.x,com2d.y + 5);

        vertex(com2d.x - 5,com2d.y);
        vertex(com2d.x + 5,com2d.y);
      endShape();
      
      fill(0,255,100);
      text(Integer.toString(userList[i]),com2d.x,com2d.y);
    }
  }    

}
//snake*****

void update(){
  snake.play();
  
  headX=headX+dirX[dir];
  headY=headY+dirY[dir];
 
  if( headX==0){
    headX=100;
  }else if( headX>100){
    headX=0;
  }else if( headY==0){
    headY=100;
  }else if( headY>100){
    headY=0;
  }

  if( eggMap[headX+headY*100]==-1){
    eggN+=fruitN;
    //fruitN++;
    eggMap[headX+headY*100]=0;
    ding.rewind();
    ding.play();
    createNextFruit();
  }
 
  eggMap[headX+headY*100]=eggN;
 
  for(int i=0;i<100*100;i++){
    if(eggMap[i]==-1){ 
      int nowX=i%100;
      int nowY=i/100;
      image(mushroom,nowX*10, nowY*10);
    }else if(eggMap[i]!=0){ 
      eggMap[i]=eggMap[i]-1;
      int nowX=i%100;
      int nowY=i/100;
      image(body,nowX*10, nowY*10);
    }
  }
  image(head,headX*10,headY*10);
}

void createNextFruit(){
  int r=int(random(50))*2+int(random(50))*200;
  if(eggMap[r]==0){
    eggMap[r]=-1;
  }else{
    createNextFruit();
  }
}

void movieEvent(Movie m) {
  m.read();
}

/*void keyPressed()
{
  if(turnright==1&&dir==0){
    dir=1;
    turnright=0;
  }else if(turnright==1&&dir==1){
    dir=2;
    turnright=0;
  }else if(turnright==1&&dir==2){
    dir=3;
    turnright=0;
  }else if(turnright==1&&dir==3){
    dir=0;
    turnright=0;
  }else if(turnleft==1&&dir==0){
    dir=3;
    turnleft=0;
  }else if(turnleft==1&&dir==1){
    dir=0;
    turnleft=0;
  }else if(turnleft==1&&dir==2){
    dir=1;
    turnleft=0;
  }else if(turnleft==1&&dir==3){
    dir=2;
    turnleft=0;
  }    
}*/

//Xtion*****

void drawSkeleton(int userId)
{
  // to get the 3d joint data
  
  PVector jointPos = new PVector();
  PVector head_jointPos = new PVector();
  PVector lefthand_jointPos = new PVector();
  PVector righthand_jointPos = new PVector();
  PVector leftelbow_jointPos = new PVector();
  PVector rightelbow_jointPos = new PVector();
  PVector leftshoulder_jointPos = new PVector();
  PVector rightshoulder_jointPos = new PVector();
  
  context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_NECK,jointPos);
  context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_HEAD,head_jointPos);
  context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_LEFT_HAND,lefthand_jointPos);
  context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_RIGHT_HAND,righthand_jointPos);
  context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_LEFT_ELBOW,leftelbow_jointPos);
  context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_RIGHT_ELBOW,rightelbow_jointPos);
  context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_LEFT_SHOULDER,leftshoulder_jointPos);
  context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_RIGHT_SHOULDER,rightshoulder_jointPos);
  
  context.convertRealWorldToProjective(head_jointPos,head_jointPos);
  context.convertRealWorldToProjective(lefthand_jointPos,lefthand_jointPos);
  context.convertRealWorldToProjective(righthand_jointPos,righthand_jointPos);
  context.convertRealWorldToProjective(leftelbow_jointPos,leftelbow_jointPos);
  context.convertRealWorldToProjective(rightelbow_jointPos,rightelbow_jointPos);
  context.convertRealWorldToProjective(leftshoulder_jointPos,leftshoulder_jointPos);
  context.convertRealWorldToProjective(rightshoulder_jointPos,rightshoulder_jointPos);

  //println(jointPos);
  //println("SKEL_NECK", userId,SimpleOpenNI.SKEL_NECK,jointPos);
  
  //fill(255);

  //println("SKEL_HEAD", userId,SimpleOpenNI.SKEL_HEAD,head_jointPos);
  //println("SKEL_LEFTHAND", userId,SimpleOpenNI.SKEL_LEFT_HAND,lefthand_jointPos);
  //println("SKEL_RIGHTHAND", userId,SimpleOpenNI.SKEL_RIGHT_HAND,righthand_jointPos);
  
  //println(lefthand_jointPos.x);
  //println(lefthand_jointPos.y);
  //println(lefthand_jointPos.z);
  
  println(head_jointPos.x);
  
  // convert real world point to projective space
  PVector jointPos_Proj = new PVector(); 
  context.convertRealWorldToProjective(jointPos,jointPos_Proj);
  
  // a 200 pixel diameter head
  float headsize = 20;
  float distanceScalar = (1000/head_jointPos.z);
 
  // set the fill colour to make the circle green
  //fill(255,255,255); 
  // draw the circle at the position of the head with the specified head size
  //image(lwing1,leftelbow_jointPos.x*25/16,leftelbow_jointPos.y*25/12);
  
  if(wingN==1){
    //ellipse(rightshoulder_jointPos.x*25/16,rightshoulder_jointPos.y*25/12, headsize,headsize);
    
  image(lwing,0,0,1,1);
  translate(leftshoulder_jointPos.x*25/16,leftshoulder_jointPos.y*25/12);
  rotate((leftshoulder_jointPos.x*25/16-leftelbow_jointPos.x*25/16)/(leftelbow_jointPos.y*25/12-leftshoulder_jointPos.y*25/12));
  image(lwing,-500,-100);
  
  image(rwing,0,0,1,1);
  translate(rightshoulder_jointPos.x*25/16-leftshoulder_jointPos.x*25/16,0/*rightshoulder_jointPos.x*25/16,rightshoulder_jointPos.y*25/12-100*/);
  rotate((rightshoulder_jointPos.x*25/16-rightelbow_jointPos.x*25/16)/(rightelbow_jointPos.y*25/12-rightshoulder_jointPos.y*25/12));
  image(rwing,0,-100);
  

  image(feather,0,0,1,1);
  translate(-500,-1000);
  rotate((leftshoulder_jointPos.x*25/16-leftelbow_jointPos.x*25/16)*3/(leftelbow_jointPos.y*25/12-leftshoulder_jointPos.y*25/12));
  image(feather,70,130);
  
  image(feather,0,0,1,1);
  //translate(leftshoulder_jointPos.x*25/16-500,leftshoulder_jointPos.y*25/12-100);
  rotate((leftshoulder_jointPos.x*25/16-leftelbow_jointPos.x*25/16)*3/(leftelbow_jointPos.y*25/12-leftshoulder_jointPos.y*25/12));
  image(feather,500,20);
  
  image(feather,0,0,1,1);
  //translate(rightshoulder_jointPos.x*25/16,rightshoulder_jointPos.y*25/12-100);
  rotate((rightshoulder_jointPos.x*25/16-rightelbow_jointPos.x*25/16)*3/(rightelbow_jointPos.y*25/12-rightshoulder_jointPos.y*25/12));
  image(feather,250,-100);
  
  image(feather,0,0,1,1);
  translate(0,1500);
  rotate((rightshoulder_jointPos.x*25/16-rightelbow_jointPos.x*25/16)*3/(rightelbow_jointPos.y*25/12-rightshoulder_jointPos.y*25/12));
  image(feather,-80,-200);
  
  image(feather,0,0,1,1);
  //translate(rightshoulder_jointPos.x*25/16,rightshoulder_jointPos.y*25/12-100);
  rotate((rightshoulder_jointPos.x*25/16-rightelbow_jointPos.x*25/16)*3/(rightelbow_jointPos.y*25/12-rightshoulder_jointPos.y*25/12));
  image(feather,500,-100);
  
  image(feather,0,0,1,1);
  //translate(leftshoulder_jointPos.x*25/16-500,leftshoulder_jointPos.y*25/12-100);
  rotate((leftshoulder_jointPos.x*25/16-leftelbow_jointPos.x*25/16)*3/(leftelbow_jointPos.y*25/12-leftshoulder_jointPos.y*25/12));
  image(feather,250,100);
  
  }
 /* translate(leftelbow_jointPos.x*25/16,leftelbow_jointPos.y*25/12);
  rotate(3);
  image(lwing1,leftelbow_jointPos.x*25/16,leftelbow_jointPos.y*25/12);
  image(lwing2,lefthand_jointPos.x*25/16,lefthand_jointPos.y*25/12);
  image(rwing1,rightelbow_jointPos.x*25/16,rightelbow_jointPos.y*25/12);
  image(rwing2,righthand_jointPos.x*25/16,righthand_jointPos.y*25/12);*/
  

  /*ellipse(head_jointPos.x*2,head_jointPos.y*2, distanceScalar*headsize,distanceScalar*headsize);
  ellipse(lefthand_jointPos.x*2,lefthand_jointPos.y*2, headsize,headsize);
  ellipse(righthand_jointPos.x*2,righthand_jointPos.y*2, headsize,headsize);
  ellipse(leftelbow_jointPos.x*2,leftelbow_jointPos.y*2, headsize,headsize);
  ellipse(rightelbow_jointPos.x*2,rightelbow_jointPos.y*2, headsize,headsize);*/
  
  /*
  text(head_jointPos.x,head_jointPos.x,head_jointPos.y);
  text(head_jointPos.y,head_jointPos.x,head_jointPos.y+30);
  
  text(lefthand_jointPos.x,lefthand_jointPos.x,lefthand_jointPos.y);
  text(lefthand_jointPos.y,lefthand_jointPos.x,lefthand_jointPos.y+30);
  
  text(righthand_jointPos.x,righthand_jointPos.x,righthand_jointPos.y);
  text(righthand_jointPos.y,righthand_jointPos.x,righthand_jointPos.y+30);
  
  text(leftelbow_jointPos.x,leftelbow_jointPos.x,leftelbow_jointPos.y);
  text(leftelbow_jointPos.y,leftelbow_jointPos.x,leftelbow_jointPos.y+30);
  
  text(rightelbow_jointPos.x,rightelbow_jointPos.x,rightelbow_jointPos.y);
  text(rightelbow_jointPos.y,rightelbow_jointPos.x,rightelbow_jointPos.y+30);

  
  
  
  
  context.drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_NECK);

  context.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_LEFT_SHOULDER);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_ELBOW);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_HAND);

  context.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND);

  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_TORSO);

  context.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_LEFT_HIP);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_HIP, SimpleOpenNI.SKEL_LEFT_KNEE);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_KNEE, SimpleOpenNI.SKEL_LEFT_FOOT);

  context.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_RIGHT_HIP);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_RIGHT_KNEE);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, SimpleOpenNI.SKEL_RIGHT_FOOT);  
  */
  
  
if(eggN<3){
  if(head_jointPos.x<300&&leftelbow_jointPos.y>lefthand_jointPos.y&&rightelbow_jointPos.y>righthand_jointPos.y){
    leancountnew=1;
  }else if(head_jointPos.x>300&&head_jointPos.x<360&&leftelbow_jointPos.y>lefthand_jointPos.y&&rightelbow_jointPos.y>righthand_jointPos.y){
    leancountnew=2;
  }else if(head_jointPos.x>360&&leftelbow_jointPos.y>lefthand_jointPos.y&&rightelbow_jointPos.y>righthand_jointPos.y){
    leancountnew=3;
  }
  if(leancountold==2&&leancountnew-leancountold==1){
    turnright=1;
  }else if(leancountold==2&&leancountnew-leancountold==-1){
    turnleft=1;
  }
  leancountold=leancountnew;
  
  if(turnright==1&&dir==0){
    dir=1;
    turnright=0;
  }else if(turnright==1&&dir==1){
    dir=2;
    turnright=0;
  }else if(turnright==1&&dir==2){
    dir=3;
    turnright=0;
  }else if(turnright==1&&dir==3){
    dir=0;
    turnright=0;
  }else if(turnleft==1&&dir==0){
    dir=3;
    turnleft=0;
  }else if(turnleft==1&&dir==1){
    dir=0;
    turnleft=0;
  }else if(turnleft==1&&dir==2){
    dir=1;
    turnleft=0;
  }else if(turnleft==1&&dir==3){
    dir=2;
    turnleft=0;
  }  
}
  
if(eggN==3){
  if(head_jointPos.y>lefthand_jointPos.y||head_jointPos.y>righthand_jointPos.y){
    liftcountnew=1;
  }else if(head_jointPos.y<lefthand_jointPos.y&&head_jointPos.y<righthand_jointPos.y){
    liftcountnew=0;
  }
  if(liftcountnew-liftcountold==1){
    liftN++;
  }
  liftcountold=liftcountnew;
}

}

// -----------------------------------------------------------------
// SimpleOpenNI events


void onNewUser(SimpleOpenNI curContext, int userId)
{
  println("onNewUser - userId: " + userId);
  println("\tstart tracking skeleton");
  
  curContext.startTrackingSkeleton(userId);
}

void onLostUser(SimpleOpenNI curContext, int userId)
{
  println("onLostUser - userId: " + userId);
}

void onVisibleUser(SimpleOpenNI curContext, int userId)
{
  //println("onVisibleUser - userId: " + userId);
  
}
