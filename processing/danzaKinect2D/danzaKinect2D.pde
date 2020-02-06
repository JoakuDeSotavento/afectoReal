/* --------------------------------------------------------------------------
 * SimpleOpenNI User Test
 * --------------------------------------------------------------------------
 * Processing Wrapper for the OpenNI/Kinect 2 library
 * http://code.google.com/p/simple-openni
 * --------------------------------------------------------------------------
 * prog:  Max Rheiner / Interaction Design / Zhdk / http://iad.zhdk.ch/
 * date:  12/12/2012 (m/d/y)
 * ----------------------------------------------------------------------------
 */

//esta es la parte de OSC

import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress dest;
NetAddress dest2;

NetAddress myRemoteLocation;
NetAddress myRemoteLocation_max;

int trackUserNum = 1;  //sets which userID to track
int trackingMode = 1;  //sets the tracking mode for OSC formatting
//using OSC barely effects the frameRate.

//major function gates
boolean trackCoM = true;
boolean trackSkeleton = true;

boolean realWorldMode = true;
boolean projectiveMode = false;
//default array of all joint IDs to track, once we have a skeleton calibrated.
int[] trackJointArray = new int[15];

//map controls -- keyboard controls Processing only
float zoomF = 0.06f;
float rotX = radians(180);  // by default rotate the hole scene 180deg around the x-axis, 
// the data from openni comes upside down
float rotY = radians(0);

//bounding box variables
float closestValue = 610; //in mm  610 = 2ft
float farthestValue = 5000; //in mm
float minimumX = -600;
float maximumX = 750;

//empty DepthMap
int[] depthMap;
//userIDs
PFont font;


// data to send to wekinator
FloatList wings;

int numBones = 12;
int numUsers = 6;

PVector[][] usedBones = new PVector[numBones][numUsers];

import SimpleOpenNI.*;

SimpleOpenNI  context;
color[]       userClr = new color[]{ color(255, 0, 0), 
  color(0, 255, 0), 
  color(0, 0, 255), 
  color(255, 255, 0), 
  color(255, 0, 255), 
  color(0, 255, 255)
};

PVector com = new PVector();                                   
PVector com2d = new PVector();                                   

//int startLoop = 0;


void setup()
{
  //startLoop= millis();

  size(640, 480, P3D);

  context = new SimpleOpenNI(this);
  if (context.isInit() == false)
  {
    println("Can't init SimpleOpenNI, maybe the camera is not connected!"); 
    exit();
    return;
  }

  // enable depthMap generation 
  context.enableDepth();

  // enable skeleton generation for all joints
  context.enableUser();

  background(200, 0, 0);

  stroke(0, 0, 255);
  strokeWeight(3);
  smooth();  

  /* start oscP5, listening for incoming messages at port 12000 */
  //oscP5 = new OscP5(this, 9000);
  //dest = new NetAddress("192.168.2.30", 10000);
  //dest2 = new NetAddress("192.168.0.144", 10000);

  oscP5 = new OscP5(this, 3301);
  // OSC output port
  myRemoteLocation = new NetAddress("127.0.0.1", 6448);
  myRemoteLocation_max = new NetAddress("127.0.0.1", 7400);



  //initialize the FloatList
  wings = new FloatList(4);

  for (int i = 0; i < numBones; i++) {
    for (int j = 0; j < numUsers; j++) {
      usedBones[i][j] = new PVector();
    }
  }


  //frameRate(12);
}



void draw()
{
  // update the cam
  context.update();

  // draw depthImageMap
  //image(context.depthImage(),0,0);
  image(context.userImage(), 0, 0);

  // draw the skeleton if it's available
  int[] userList = context.getUsers();
  for (int i=0; i<userList.length; i++)
  {
    if (context.isTrackingSkeleton(userList[i]))
    {
      stroke(userClr[ (userList[i] - 1) % userClr.length ] );
      drawSkeleton(userList[i]);

      if (userList.length == 1) {

        //context.getJointPositionSkeleton(userList[0], SimpleOpenNI.SKEL_LEFT_HAND, usedBones[0][0]);
        //context.getJointPositionSkeleton(userList[0], SimpleOpenNI.SKEL_RIGHT_HAND, usedBones[1][0]);
        //context.getJointPositionSkeleton(userList[0], SimpleOpenNI.SKEL_LEFT_HIP, usedBones[2][0]);
        //context.getJointPositionSkeleton(userList[0], SimpleOpenNI.SKEL_RIGHT_HIP, usedBones[3][0]);
        //context.getJointPositionSkeleton(userList[0], SimpleOpenNI.SKEL_HEAD, usedBones[4][0]);
        //context.getJointPositionSkeleton(userList[0], SimpleOpenNI.SKEL_TORSO, usedBones[5][0]);

        //float distHand = PVector.dist(usedBones[0][0], usedBones[1][0]);
        //float angleLeft = PVector.angleBetween(usedBones[0][0], usedBones[2][0]);
        //float angleRigth = PVector.angleBetween(usedBones[1][0], usedBones[3][0]);
        //float angleBody = PVector.angleBetween(usedBones[4][0], usedBones[5][0]);
        sendOSCeleton(trackUserNum, getSpecificUserJoints(trackUserNum, trackJointArray)); //@see OSC_output
        //sendOsc(distHand, degrees(angleLeft), degrees(angleRigth), degrees(angleBody));
        //println(trackJointArray);
      }
    }

    //// draw the center of mass
    //if (context.getCoM(userList[i], com))
    //{
    //  context.convertRealWorldToProjective(com, com2d);
    //  stroke(100, 255, 0);
    //  strokeWeight(1);
    //  beginShape(LINES);
    //  vertex(com2d.x, com2d.y - 5);
    //  vertex(com2d.x, com2d.y + 5);

    //  vertex(com2d.x - 5, com2d.y);
    //  vertex(com2d.x + 5, com2d.y);
    //  endShape();

    //  fill(0, 255, 100);
    //  text(Integer.toString(userList[i]), com2d.x, com2d.y);
    //}
  }
}

//void sendOsc(float _dist, float _angleLeft, float _angleRigth, float _angleBody) {
//  // this creat the Osc message
//  OscMessage msg = new OscMessage("/inputs");
//  //this decompress the FloatList and makes the Osc message

//  msg.add(_dist);
//  msg.add(_angleLeft);
//  msg.add(_angleRigth);
//  msg.add(_angleBody);

//  //this send the message
//  oscP5.send(msg, dest);
//  //  oscP5.send(msg, dest2);
//}
// draw the skeleton with the selected joints
void drawSkeleton(int userId)
{
  // to get the 3d joint data
  /*
  PVector jointPos = new PVector();
   context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_NECK,jointPos);
   println(jointPos);
   */

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

  // setup();
  println("onLostUser - userId: " + userId);
}

void onVisibleUser(SimpleOpenNI curContext, int userId)
{
  //println("onVisibleUser - userId: " + userId);
}


void keyPressed()
{
  switch(key)
  {
  case ' ':
    context.setMirror(!context.mirror());
    break;
  }
}  
