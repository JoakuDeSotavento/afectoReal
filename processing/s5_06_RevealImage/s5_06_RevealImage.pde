import SimpleOpenNI.*;

SimpleOpenNI  context;

PImage imgC, imgBW;

int HALF_HOLE_SIZE = 30;

boolean bPersist = false;

void setup()
{
  size(1800, 960);
  context = new SimpleOpenNI(this);

  context.enableDepth();


  context.enableUser();

  //size(640*2, 480);
  // Load a color image
  imgC = loadImage("aztecas.jpg");
  // Load a black & white image (the same)
  imgBW = loadImage("aztecas2.jpg");
  // Indicate we need transparency on this image
  imgBW.format = ARGB;
  stroke(0, 0, 255);
  smooth();
  background(255);

  //size(imgC.width+context.depthWidth(), imgC.height);
}

void draw()
{ 

  context.update();

  context.setMirror(true);  

  image(imgC, 0, 0); 
  image(imgBW, 0, 0);    
  image(context.depthImage(), imgC.width, 0);   

  if (context.isTrackingSkeleton(1)) {
    revealImage(1);
  }

  PVector jointPosLeft = new PVector();
  PVector jointPosRight = new PVector();  

  PVector screenPosLeft= new PVector();
  PVector screenPosRight= new PVector();  

  context.getJointPositionSkeleton(0, SimpleOpenNI.SKEL_LEFT_HAND, jointPosLeft);
  context.convertRealWorldToProjective(jointPosLeft, screenPosLeft);  

  context.getJointPositionSkeleton(0, SimpleOpenNI.SKEL_RIGHT_HAND, jointPosRight);
  context.convertRealWorldToProjective(jointPosRight, screenPosRight);  

  // Make pixels transparent around the mouse position
  ChangePixels(int(screenPosLeft.x), int(screenPosLeft.y), false);
  ChangePixels(int(screenPosRight.x), int(screenPosRight.y), false);  

  ellipse(screenPosLeft.x, screenPosLeft.y, 30, 30);
  ellipse(screenPosRight.x, screenPosRight.y, 30, 30);
} 

void revealImage(int userId)
{
  // to get the 3d joint data

  PVector jointPosLeft = new PVector();
  PVector jointPosRight = new PVector();  

  PVector screenPosLeft= new PVector();
  PVector screenPosRight= new PVector();  

  context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_HAND, jointPosLeft);
  context.convertRealWorldToProjective(jointPosLeft, screenPosLeft);  

  context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_HAND, jointPosRight);
  context.convertRealWorldToProjective(jointPosRight, screenPosRight);  

  // Make pixels transparent around the mouse position
  //ChangePixels(int(screenPosLeft.x),int(screenPosLeft.y), false);
  //ChangePixels(int(screenPosRight.x),int(screenPosRight.y), false);  

  ellipse(screenPosLeft.x, screenPosLeft.y, 30, 30);
  ellipse(screenPosRight.x, screenPosRight.y, 30, 30);
}

void ChangePixels(int x, int y, boolean bMakeOpaque)
{
  // Primitive, lazy tests, should be improved (
  if (x <= HALF_HOLE_SIZE || x >= imgBW.width - HALF_HOLE_SIZE) return;
  if (y <= HALF_HOLE_SIZE || y >= imgBW.height - HALF_HOLE_SIZE) return;
  // Get the pixel data
  imgBW.loadPixels();
  // Walk a square around the given position
  for (int i = x - HALF_HOLE_SIZE; i <= x + HALF_HOLE_SIZE; i++)
  {
    for (int j = y - HALF_HOLE_SIZE; j <= y + HALF_HOLE_SIZE; j++)
    {
      if (bMakeOpaque)
      {
        imgBW.pixels[i + j * imgBW.width] |= 0xFF000000;
      } else // Make transparent
      {
        imgBW.pixels[i + j * imgBW.width] &= 0x00FFFFFF;
      }
    }
  }
  // Update the modified pixels
  imgBW.updatePixels();
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



//void onStartCalibration(int userId)
//{
//  println("onStartCalibration - userId: " + userId);
//}
//
//void onEndCalibration(int userId, boolean successfull)
//{
//  println("onEndCalibration - userId: " + userId + ", successfull: " + successfull);
//  
//  if (successfull) 
//  { 
//    println("  User calibrated !!!");
//    context.startTrackingSkeleton(userId); 
//  } 
//  else 
//  { 
//    println("  Failed to calibrate user !!!");
//    println("  Start pose detection");
//    context.startPoseDetection("Psi",userId);
//  }
//}
//
//void onStartPose(String pose,int userId)
//{
//  println("onStartPose - userId: " + userId + ", pose: " + pose);
//  println(" stop pose detection");
//  
//  context.stopPoseDetection(userId); 
//  context.requestCalibrationSkeleton(userId, true);
// 
//}
//
//void onEndPose(String pose,int userId)
//{
//  println("onEndPose - userId: " + userId + ", pose: " + pose);
//}
