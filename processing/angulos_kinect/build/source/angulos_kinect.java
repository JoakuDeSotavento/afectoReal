import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import SimpleOpenNI.*; 
import processing.serial.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class angulos_kinect extends PApplet {


SimpleOpenNI kinect;


Serial port;

public void setup() {

  
  kinect = new SimpleOpenNI(this);
  kinect.enableDepth();
  kinect.enableUser();
  kinect.setMirror(true);

  println(Serial.list());
  String portName = Serial.list()[0];
  port = new Serial(this, portName, 9600);
}

public void draw() {
  kinect.update();
  PImage depth = kinect.depthImage();
  image(depth, 0, 0);

  IntVector userList = new IntVector();
  kinect.getUsers(userList);
  if (userList.size() > 0) {
    int userId = userList.get(0);
    if ( kinect.isTrackingSkeleton(userId)) {

      float myElbow = giveMeAngle(userId, SimpleOpenNI.SKEL_RIGHT_HAND, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
      float myShoulder = giveMeAngle(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_HIP);

      // get the positions of the three joints of our arm
      PVector rightHand = new PVector();
      kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_HAND, rightHand);
      PVector rightElbow = new PVector();
      kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, rightElbow);
      PVector rightShoulder = new PVector();
      kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, rightShoulder);
      // we need right hip to orient the shoulder angle
      PVector rightHip = new PVector();
      kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_HIP, rightHip);
      // reduce our joint vectors to two dimensions
      PVector rightHand2D = new PVector(rightHand.x, rightHand.y);
      PVector rightElbow2D = new PVector(rightElbow.x, rightElbow.y);
      PVector rightShoulder2D = new PVector(rightShoulder.x, rightShoulder.y);
      PVector rightHip2D = new PVector(rightHip.x, rightHip.y);
      // calculate the axes against which we want to measure our angles
      PVector torsoOrientation = PVector.sub(rightShoulder2D, rightHip2D);
      PVector upperArmOrientation = PVector.sub(rightElbow2D, rightShoulder2D);
      // calculate the angles between our joints
      float shoulderAngle = angleOf(rightElbow2D, rightShoulder2D, torsoOrientation);
      float elbowAngle = angleOf(rightHand2D, rightElbow2D, upperArmOrientation);

      //////////////////////////////////////////////////////////////
      byte out[] = new byte[4];
      out[0] = PApplet.parseByte(PApplet.parseInt(shoulderAngle));
      out[1] = PApplet.parseByte(PApplet.parseInt(elbowAngle));
      out[2] = PApplet.parseByte(PApplet.parseInt(myShoulder));
      out[3] = PApplet.parseByte(PApplet.parseInt(myElbow));
      port.write(out);
      /////////////////////////////////////////////////////////////
      // show the angles on the screen for debugging

      fill(255, 0, 0);
      scale(3);
      text("shoulder: " + PApplet.parseInt(shoulderAngle) + "\n" +
          " elbow: " + PApplet.parseInt(elbowAngle) + "\n" +
          " my shoulder: " + PApplet.parseInt(myShoulder) + "\n" +
          " my elbow: " + PApplet.parseInt(myElbow), 20, 20);
    }
  }
}

// you need three points
public float giveMeAngle(int _user, int _one, int _two, int _three){
// getting the Vector 3D of three axis
  PVector firstPoint = new PVector();
  kinect.getJointPositionSkeleton(_user, _one, firstPoint);
  PVector secondPoint = new PVector();
  kinect.getJointPositionSkeleton(_user, _two, secondPoint);
  PVector thirdPoint = new PVector();
  kinect.getJointPositionSkeleton(_user, _three, thirdPoint);
// diminiss 3D vectors to random2D
  PVector firstPoint2D = new PVector(firstPoint.x, firstPoint.y);
  PVector secondPoint2D = new PVector(secondPoint.x, secondPoint.y);
  PVector thirdPoint2D = new PVector(thirdPoint.x, thirdPoint.y);
// calculate the axes against which we want to measure our angles
  PVector axis = PVector.sub(secondPoint, thirdPoint);
// calculate the angles between our joints
// first point, second point and the orientation
  float theAngle = angleOf(firstPoint2D, secondPoint2D, axis);
  return theAngle;
}

public float angleOf(PVector one, PVector two, PVector axis) {
  PVector limb = PVector.sub(two, one);
  return degrees(PVector.angleBetween(limb, axis));
}


// -----------------------------------------------------------------
// SimpleOpenNI user events

public void onNewUser(SimpleOpenNI curContext, int userId)
{
  println("onNewUser - userId: " + userId);
  println("\tstart tracking skeleton");

  kinect.startTrackingSkeleton(userId);
}

public void onLostUser(SimpleOpenNI curContext, int userId)
{
  println("onLostUser - userId: " + userId);
}

public void onVisibleUser(SimpleOpenNI curContext, int userId)
{
  //println("onVisibleUser - userId: " + userId);
}
  public void settings() {  size(640, 480); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "angulos_kinect" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
