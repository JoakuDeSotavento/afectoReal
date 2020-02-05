import SimpleOpenNI.*;
SimpleOpenNI kinect;

import processing.serial.*;
Serial port;

void setup() {

  size(640, 480);
  kinect = new SimpleOpenNI(this);
  kinect.enableDepth();
  kinect.enableUser();
  kinect.setMirror(true);

  println(Serial.list());
  String portName = Serial.list()[0];
  port = new Serial(this, portName, 9600);
}

void draw() {
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
      out[0] = byte(int(shoulderAngle));
      out[1] = byte(int(elbowAngle));
      out[2] = byte(int(myShoulder));
      out[3] = byte(int(myElbow));
      port.write(out);
      /////////////////////////////////////////////////////////////
      // show the angles on the screen for debugging

      fill(255, 0, 0);
      scale(3);
      text("shoulder: " + int(shoulderAngle) + "\n" +
          " elbow: " + int(elbowAngle) + "\n" +
          " my shoulder: " + int(myShoulder) + "\n" +
          " my elbow: " + int(myElbow), 20, 20);
    }
  }
}

// you need three points
float giveMeAngle(int _user, int _one, int _two, int _three){
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

float angleOf(PVector one, PVector two, PVector axis) {
  PVector limb = PVector.sub(two, one);
  return degrees(PVector.angleBetween(limb, axis));
}


// -----------------------------------------------------------------
// SimpleOpenNI user events

void onNewUser(SimpleOpenNI curContext, int userId)
{
  println("onNewUser - userId: " + userId);
  println("\tstart tracking skeleton");

  kinect.startTrackingSkeleton(userId);
}

void onLostUser(SimpleOpenNI curContext, int userId)
{
  println("onLostUser - userId: " + userId);
}

void onVisibleUser(SimpleOpenNI curContext, int userId)
{
  //println("onVisibleUser - userId: " + userId);
}
